terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "ecs"
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

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}
