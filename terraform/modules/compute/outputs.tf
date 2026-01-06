# -----------------------------------------------------------------------------
# COMPUTE MODULE OUTPUTS
# -----------------------------------------------------------------------------

output "vm_ids" {
  description = "List of virtual machine IDs"
  value       = azurerm_linux_virtual_machine.main[*].id
}

output "vm_names" {
  description = "List of virtual machine names"
  value       = azurerm_linux_virtual_machine.main[*].name
}

output "vm_private_ips" {
  description = "List of private IP addresses"
  value       = azurerm_network_interface.main[*].private_ip_address
}

output "vm_identity_principal_ids" {
  description = "List of managed identity principal IDs"
  value       = [for vm in azurerm_linux_virtual_machine.main : vm.identity[0].principal_id]
}

output "vm_identity_tenant_ids" {
  description = "List of managed identity tenant IDs"
  value       = [for vm in azurerm_linux_virtual_machine.main : vm.identity[0].tenant_id]
}

output "nic_ids" {
  description = "List of network interface IDs"
  value       = azurerm_network_interface.main[*].id
}
