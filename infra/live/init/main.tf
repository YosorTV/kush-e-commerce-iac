terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

module "init" {
  source                      = "../../modules/init"
  terraform_state_bucket_name = "${var.name}-tf-state"
  region                      = var.region
}
