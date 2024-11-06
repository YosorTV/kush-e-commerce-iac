terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "vpc"
  }
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

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.cidr

  azs            = ["eu-central-1a", "eu-central-1b"]
  public_subnets = var.public_subnets

  create_igw = true

  tags = local.tags
}
