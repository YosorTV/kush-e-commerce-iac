terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "ecr"
  }
}

provider "aws" {
  region = var.region
}

locals {
  name = "kush-${var.environment}"
  name_backend = var.environment == "dev" ? "kush-e-commerce-back": "kush-e-commerce-back-${var.environment}"
  name_frontend = var.environment == "dev" ? "kush-e-commerce-frontend": "kush-e-commerce-frontend-${var.environment}"
  tags = {
    "Environment" : var.environment
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = local.name_backend
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "frontend" {
  name                 = local.name_frontend
  image_tag_mutability = "IMMUTABLE"
}