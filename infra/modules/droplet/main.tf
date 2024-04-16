locals {
  volumes = flatten([
    for item in var.droplets : [
      for volume in coalesce(item.volumes, []) : {
        name                    = volume.name
        size                    = volume.size
        initial_filesystem_type = volume.initial_filesystem_type
        mountpoint              = volume.mountpoint
        region                  = item.region
        droplet_name            = item.name
      } if item.volumes != null
    ]
  ])
}

locals {
  volumes_list = tomap({
    for item in var.droplets : item.name => item.volumes
  })
}


resource "digitalocean_volume" "volume" {
  for_each = { for item in local.volumes : item.name => item }

  region                   = each.value.region
  name                     = each.value.name
  size                     = each.value.size
  initial_filesystem_type  = each.value.initial_filesystem_type
  initial_filesystem_label = each.value.name
}

data "template_file" "volumes_template" {

  for_each = { for item in local.volumes : item.name => item }

  template = file("${path.module}/volumes.tpl")
  vars = {
    MOUNTPOINT = each.value.mountpoint
    LABEL      = each.value.name
    FS_TYPE    = each.value.initial_filesystem_type
  }
}

locals {
  template_list = tomap(
    { for item in var.droplets: item.name =>
        [for volume in coalesce(item.volumes, []): data.template_file.volumes_template[volume.name].rendered ]  }
  )
}

data "template_file" "user_data" {
  for_each = { for item in var.droplets : item.name => item }
  template = file("${path.module}/user_data.tpl")

  vars = {
    VOLUMES_COMANDS = join("\n", [for volume in coalesce(each.value.volumes, []) : data.template_file.volumes_template[volume.name].rendered])
    SSH_KEYS = join("\n", each.value.ssh_keys )
    ADDITIONAL_USERDATA = try(each.value.userdata_custom_addon, "")
    GITHUB_RUNNER_URL = each.value.github_runner_url
    GITHUB_RUNNER_TOKEN = each.value.github_runner_token
  }
}
resource "digitalocean_droplet" "droplet" {
  for_each = { for item in var.droplets : item.name => item }
  name     = each.value.name
  image    = each.value.image
  region   = each.value.region
  size     = each.value.size
  vpc_uuid = try(each.value.vpc_uuid, null)
  ssh_keys = [for key in coalesce(each.value.ssh_keys_fingerprints, []) : key]
  user_data = data.template_file.user_data[each.value.name].rendered
  tags = try(each.value.tags,[])
}

resource "digitalocean_volume_attachment" "volume_attachment" {
  for_each   = { for item in local.volumes : item.name => item }
  droplet_id = digitalocean_droplet.droplet[each.value.droplet_name].id
  volume_id  = digitalocean_volume.volume[each.value.name].id
}

locals {
  hosts = {
    for droplet in digitalocean_droplet.droplet :
    droplet.name => { ansible_host : digitalocean_droplet.droplet[droplet.name].ipv4_address }

  }
  instances = flatten([
    for droplet in digitalocean_droplet.droplet : [droplet.name]
  ])
}

resource "local_file" "inventory" {
  count = var.generate_ansible_inventory == false ? 0 : 1

  content = yamlencode(
      {
        all : { hosts : local.hosts }, instances : { hosts : local.instances }
      }
    )


  filename = "inventory.yml"
}
