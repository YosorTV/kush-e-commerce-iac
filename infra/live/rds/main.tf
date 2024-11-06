terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "rds"
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

resource "aws_db_parameter_group" "custom_pg" {
  name        = "${local.name}-pg"
  family      = "postgres15"
  description = "Custom parameter group for ${local.name}"

  tags = local.tags

  # Set the rds.force_ssl parameter to 0
  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "pending-reboot" # or "immediate" if it needs to take effect immediately
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier             = local.name
  engine                 = "postgres"
  engine_version         = "15.7"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  db_name                = "api"
  username               = "strapi_admin"
  port                   = "5432"
  vpc_security_group_ids = data.terraform_remote_state.ecs.outputs.security_group_ids
  backup_window          = "03:00-06:00"
  tags                   = local.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Database Deletion Protection
  deletion_protection  = true
  publicly_accessible  = true
  family               = "postgres15"
  parameter_group_name = aws_db_parameter_group.custom_pg.name
}
