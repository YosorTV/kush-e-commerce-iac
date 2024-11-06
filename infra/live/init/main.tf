terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend "s3" {
  #   key = "init"
  # }
}

provider "aws" {
  region = var.region
}

locals {
  name = "kush-${var.environment}"
  tags = {
    "Environment" : var.environment
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = "${local.name}-5uggyhw-tf-state"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  versioning = {
    enabled = true
  }
  tags = local.tags
}