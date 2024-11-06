terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "ci/backend"
  }
}

provider "aws" {
  region = var.region
}

locals {
  name = "kush-backend-${var.environment}"
  tags = {
    "Environment" : var.environment
  }
}

data "aws_codestarconnections_connection" "connection" {
  name = "test"
}

module "build" {
  source             = "cloudposse/codebuild/aws"
  name               = local.name
  build_image        = "aws/codebuild/standard:2.0"
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_timeout      = 60
  privileged_mode    = true
  environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
      type  = "PLAINTEXT"
    },
    # {
    #   name  = "APP_KEYS"
    #   value = var.region
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "HOST"
    #   value = "0.0.0.0"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "PORT"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "API_TOKEN_SALT"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "ADMIN_JWT_SECRET"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "JWT_SECRET"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "API_TOKEN_SALT"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "ADMIN_JWT_SECRET"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "JWT_SECRET"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "TRANSFER_TOKEN_SALT"
    #   value = "1337"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_CLIENT"
    #   value = "postgres"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_HOST"
    #   value = "kush-dev.cpoeg2ikgxrl.eu-central-1.rds.amazonaws.com"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_PORT"
    #   value = "5432"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_NAME"
    #   value = "api"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_USERNAME"
    #   value = "strapi_admin"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_PASSWORD"
    #   value = "-MuFtUwsD|:QR#oPdHb)$e]dx*9x"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "DATABASE_SSL"
    #   value = "false"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "SMTP_PASSWORD"
    #   value = "re_4JrtYSot_8PbZoLo2EUCsZA9uJErKkKH6"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "PUBLIC_URL"
    #   value = "https://dev.kush-test.pp.ua/strapi"
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "CLOUDINARY_NAME"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "CLOUDINARY_KEY"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "CLOUDINARY_SECRET"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "STRIPE_SECRET_KEY"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "STRIPE_PUBLIC_KEY"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    # {
    #   name  = "STRIPE_WEBHOOK_SECRET"
    #   value = ""
    #   type  = "PLAINTEXT"
    # },
    {
      name  = "S3_BUCKET"
      value = "s3://${var.terraform_state_bucket}"
      type  = "PLAINTEXT"
    },
    {
      name  = "ENVIRONMENT"
      value = var.environment
      type  = "PLAINTEXT"
    },
    {
      name  = "TERRAFORM_STATE_BUCKET"
      value = var.terraform_state_bucket
      type  = "PLAINTEXT"
    },
  ]
}

resource "aws_codepipeline" "codepipeline" {
  name     = local.name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.connection.arn
        FullRepositoryId = "YosorTV/kush-e-commerce-back"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = module.build.project_name
      }
    }
  }

}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${local.name}-5uggyhw"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.name}-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:*",
    ]

    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:*"]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${local.name}-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_policy" "policy" {
  name   = "${local.name}-policy"
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = module.build.project_name
  policy_arn = aws_iam_policy.policy.arn
}

