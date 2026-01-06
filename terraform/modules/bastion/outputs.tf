# -----------------------------------------------------------------------------
# BASTION MODULE OUTPUTS
# -----------------------------------------------------------------------------

output "bastion_id" {
  description = "ID of the Bastion host"
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "Name of the Bastion host"
  value       = azurerm_bastion_host.main.name
}

output "bastion_dns_name" {
  description = "DNS name of the Bastion host"
  value       = azurerm_bastion_host.main.dns_name
}

output "public_ip_id" {
  description = "ID of the Bastion public IP"
  value       = azurerm_public_ip.bastion.id
}

output "public_ip_address" {
  description = "Public IP address of the Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}
