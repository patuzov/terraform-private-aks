output "jumpbpx_ip" {
  description = "Jumpbox IP Address"
  value       = module.jumpbox.jumpbox_ip
}

output "jumpbox_username" {
  description = "Jumpbox Username"
  value       = module.jumpbox.jumpbox_username
}

output "jumpbox_password" {
  description = "Jumpbox Admin Passowrd"
  value       = module.jumpbox.jumpbox_password
}

output "ssh_command" {
  value = "ssh ${module.jumpbox.jumpbox_username}@${module.jumpbox.jumpbox_ip}"
}