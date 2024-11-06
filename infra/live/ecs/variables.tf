variable "environment" {}
variable "region" {
  default = "eu-central-1"
}
variable "cidr" {}
variable "public_subnets" {}
variable "terraform_state_bucket" {}
variable "frontend_port" {
  default = "3000"
}
variable "backend_port" {
  default = "1337"
}
variable "instance_type" {
  default = "t3.small"
}
variable "ssh_keys" {}
variable "frontend_domain"{}
variable "backend_domain"{}
variable "certifiate_arn" {}