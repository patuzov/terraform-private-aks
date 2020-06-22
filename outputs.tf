output "jumpbpx_ip" {
  description = "Jumpbox IP Address"
  value       = module.jumpbox.jumpbox_ip
}

output "jumpbox_username" {
  description = "Jumpbox Username"
  value       = module.jumpbox.jumpbox_username
}

output "jumpbox_ssh" {
  description = "Jumpbox SSH key"
  value       = module.jumpbox.tls_private_key
}
