## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | ~> 2.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_droplets"></a> [droplets](#input\_droplets) | droplets list | <pre>list(object({<br>    image  = string<br>    name   = string<br>    region = string<br>    size   = string<br>    ssh_keys = optional(list(object({<br>      name    = string<br>      ssh_key = string<br>    })))<br>    ssh_keys_test         = optional(list(string))<br>    ssh_keys_fingerprints = optional(list(string))<br>    volumes = optional(list(object({<br>      name                    = string<br>      size                    = number<br>      initial_filesystem_type = string<br>      mountpoint              = string<br>    })))<br>    vpc_uuid = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_droplet_ids"></a> [droplet\_ids](#output\_droplet\_ids) | map of the Digital Ocean droplet names to their ids |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | map of the Digital Ocean droplet names to their corresponding public IPv4 addresses. |


## Example usage
```
data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    endpoint                    = "nyc3.digitaloceanspaces.com"
    bucket = "tf-state-bucket"
    key  = "database"
    region = "ap-southeast-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

resource "digitalocean_ssh_key" "ssh_key_liubov" {
  name       = "liubov"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLo0ycyXJD0D1z55zP4ZPr2iuQWUqKT6D6goTS3g/238wR81A5TpxLDmCUsfK7WjbGVKUXv/CorUIJyNFomqqdx9ds8EQ1m1MzvV51DtmHY6jZOdJbooDRLMs+SbTYj8cK0FKCM5Kq0/tG2NKHKoTUieHRnMetg+Ju1JiARMEEI8HwRZzfCdgubBa8QbeQscIOX764I4oGV3SsPEt3b/4kf7qfjY22GEIJ5qBInpq1GUWKgm5eUX9tERaCUaMPiTycduNMY6fxeMvFV/lHeH/Xg1dPg0owx3+KX1qOJLE5eYP1KmhR0wa6nkFtGtm4C+hpNrrMMq0f2mKI2QU6+axxVbPZyneVYYvVqiOay0e5gEKbWL5iqg7AK3buct5gDg0DiYdmLY14zHOdus9SfWdZj09UTh6rZfVnvDI+Rzx4+yJ+oLItZv3MY7mLRzWZzPPLZy4aEmMcGkTYMvoihDD4L9iwSZ75bxlkOkZrAJaBqdr6fGWe77YNMXwZAPPUqwk= mac@MACs-MacBook-Pro.local"
}


module "droplet" {
  source   = "../../modules/droplet"
  droplets = [
  {
    image    = "ubuntu-20-04-x64"
    name     = "terraform-test1"
    region   = "nyc1"
    size     = "s-1vcpu-1gb-intel"
    vpc_uuid = data.terraform_remote_state.database.outputs.vpc_uuid
    volumes = [
      {
        name                    = "vol1-test"
        size                    = 1
        initial_filesystem_type = "ext4"
        mountpoint              = "/mnt/mountpoint1"
      }, 
      {
        name                    = "vol2-test"
        size                    = 1
        initial_filesystem_type = "ext4"
        mountpoint              = "/mnt/mountpoint2"
      }
    
    
    ]
    ssh_keys_fingerprints = [ digitalocean_ssh_key.ssh_key_liubov.fingerprint ]
  }

]
}


```