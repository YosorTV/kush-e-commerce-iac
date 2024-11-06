variable "terraform_state_bucket_name" {
    type = string
    description = "name of terraform state bucket"
}

variable "tags" {
    type = map(string)
    description = "tags to apply to bucket"
    default = {}
}
