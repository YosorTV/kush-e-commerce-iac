output "terraform-state-bucket-name" {
  value = digitalocean_spaces_bucket.terraform_state_bucket.id
  description = "name of terraform state bucket"
}

output "terraform-state-bucket-name-endpoint" {
  value = digitalocean_spaces_bucket.terraform_state_bucket.endpoint
  description = "endpoint of terraform state bucket"
}

