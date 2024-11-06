data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "vpc"
    region = var.region
  }
}
