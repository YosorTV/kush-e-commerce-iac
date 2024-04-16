variable "terraform_state_bucket_name" {
    type = string
    description = "name of terraform state bucket"
}

variable "region" {
    type = string
    description = "region to create terraform state bucket in"
}
