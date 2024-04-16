variable "droplets" {
  type = list(object({
    image  = string
    name   = string
    region = string
    size   = string
    userdata_custom_addon = optional(string)
    ssh_keys_fingerprints = optional(list(string))
    ssh_keys              = list(string)
    volumes = optional(list(object({
      name                    = string
      size                    = number
      initial_filesystem_type = string
      mountpoint              = string
    })))
    vpc_uuid = optional(string)
    tags = optional(list(string))
    github_runner_url = optional(string)
    github_runner_token = optional(string)
  }))

  description = "droplets list"

}

variable "generate_ansible_inventory" {
   type = bool
   default = false

}
