terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
  backend "s3" {
    key = "droplet"
  }
}

module "droplet" {
  source                     = "../../modules/droplet"
  droplets                   = var.droplets
  generate_ansible_inventory = var.generate_ansible_inventory
}
