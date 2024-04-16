resource "digitalocean_spaces_bucket" "terraform_state_bucket" {
  name   = var.terraform_state_bucket_name
  region = var.region
  acl = "private"
  versioning {
    enabled = true
  }

}
