module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.terraform_state_bucket_name
  acl    = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership = "ObjectWriter"
  versioning = {
    enabled = true
  }
  tags = var.tags
}
