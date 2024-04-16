## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | region to create terraform state bucket in | `string` | n/a | yes |
| <a name="input_terraform_state_bucket_name"></a> [terraform\_state\_bucket\_name](#input\_terraform\_state\_bucket\_name) | name of terraform state bucket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_terraform-state-bucket-name"></a> [terraform-state-bucket-name](#output\_terraform-state-bucket-name) | name of terraform state bucket |
| <a name="output_terraform-state-bucket-name-endpoint"></a> [terraform-state-bucket-name-endpoint](#output\_terraform-state-bucket-name-endpoint) | endpoint of terraform state bucket |

## Example usage
To configure space bucket for usage you may use this [article](https://anichakraborty.medium.com/terraform-remote-state-backup-with-digital-ocean-spaces-697e35128a6a)
```
# Uncomment it after initial init and apply, and then follow up with init to import.
# terraform {
#   backend "s3" {
#     endpoint                    = "nyc3.digitaloceanspaces.com"
#     bucket = "tf-state-bucket"
#     key  = "init"
#     region = "ap-southeast-1"
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#   }
# }

module "init" {
    source = "../../modules/init"
    terraform_state_bucket_name = "tf-state-bucket"
    region = "nyc3"
}

```

