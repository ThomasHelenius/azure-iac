# -----------------------------------------------------------------------------
# OUTPUTS
# Values exported for use by other configurations or for reference
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# RESOURCE GROUP OUTPUTS
# -----------------------------------------------------------------------------

output "resource_group_ids" {
  description = "Map of resource group names to their IDs"
  value = {
    network  = azurerm_resource_group.network.id
    compute  = azurerm_resource_group.compute.id
    security = azurerm_resource_group.security.id
    monitor  = azurerm_resource_group.monitor.id
  }
}

output "resource_group_names" {
  description = "Map of resource group names"
  value       = local.resource_groups
}

# -----------------------------------------------------------------------------
# NETWORKING OUTPUTS
# -----------------------------------------------------------------------------

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.networking.nsg_ids
}

# -----------------------------------------------------------------------------
# COMPUTE OUTPUTS
# -----------------------------------------------------------------------------

output "vm_ids" {
  description = "List of virtual machine IDs"
  value       = module.compute.vm_ids
}

output "vm_names" {
  description = "List of virtual machine names"
  value       = module.compute.vm_names
}

output "vm_private_ips" {
  description = "List of private IP addresses assigned to VMs"
  value       = module.compute.vm_private_ips
}

output "vm_identity_principal_ids" {
  description = "List of managed identity principal IDs for VMs"
  value       = module.compute.vm_identity_principal_ids
}

# -----------------------------------------------------------------------------
# SECURITY OUTPUTS
# -----------------------------------------------------------------------------

output "keyvault_id" {
  description = "ID of the Key Vault"
  value       = module.keyvault.keyvault_id
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.keyvault_uri
}

# -----------------------------------------------------------------------------
# BASTION OUTPUTS
# -----------------------------------------------------------------------------

output "bastion_id" {
  description = "ID of the Bastion host"
  value       = var.enable_bastion ? module.bastion[0].bastion_id : null
}

output "bastion_dns_name" {
  description = "DNS name of the Bastion host"
  value       = var.enable_bastion ? module.bastion[0].bastion_dns_name : null
}

# -----------------------------------------------------------------------------
# MONITORING OUTPUTS
# -----------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.monitoring.application_insights_id
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# CONVENIENCE OUTPUTS
# -----------------------------------------------------------------------------

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "location" {
  description = "Azure region"
  value       = var.location
}

output "bastion_connect_command" {
  description = "Azure CLI command to connect to VM via Bastion"
  value       = var.enable_bastion && length(module.compute.vm_ids) > 0 ? "az network bastion ssh --name ${local.bastion_name} --resource-group ${local.resource_groups.network} --target-resource-id ${module.compute.vm_ids[0]} --auth-type ssh-key --username ${var.vm_admin_username} --ssh-key <path-to-private-key>" : "Bastion not enabled"
}
