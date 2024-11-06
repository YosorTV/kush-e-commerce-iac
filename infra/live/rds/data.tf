data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "vpc"
    region = var.region
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "ecs"
    region = var.region
  }
}

