output "tls_private_key" {
  description = "Jumpbox VM SSH key"
  value       = "${tls_private_key.jumpbox_ssh.private_key_pem}"
}

output "jumpbox_username" {
  description = "Jumpbox VM username"
  value       = var.vm_user
}

output "jumpbox_ip" {
  description = "Jumpbox VM IP"
  value       = azurerm_public_ip.pip.ip_address
}