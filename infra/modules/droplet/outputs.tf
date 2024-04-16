output "public_ips" {
  value       = { for item in var.droplets : item.name => digitalocean_droplet.droplet[item.name].ipv4_address }
  description = "map of the Digital Ocean droplet names to their corresponding public IPv4 addresses."
}

output "droplet_ids" {
  value       = { for item in var.droplets : item.name => digitalocean_droplet.droplet[item.name].id }
  description = "map of the Digital Ocean droplet names to their ids"
}

output "rendered_userdata" {
  value = { for item in var.droplets : item.name => data.template_file.user_data[item.name].rendered }
}

output "droplets" {
  value = { for item in var.droplets : item.name => digitalocean_droplet.droplet[item.name] }

}
