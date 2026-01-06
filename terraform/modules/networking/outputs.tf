# -----------------------------------------------------------------------------
# NETWORKING MODULE OUTPUTS
# -----------------------------------------------------------------------------

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    compute          = azurerm_subnet.compute.id
    data             = azurerm_subnet.data.id
    private_endpoint = azurerm_subnet.private_endpoint.id
    bastion          = azurerm_subnet.bastion.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    compute          = azurerm_subnet.compute.address_prefixes[0]
    data             = azurerm_subnet.data.address_prefixes[0]
    private_endpoint = azurerm_subnet.private_endpoint.address_prefixes[0]
    bastion          = azurerm_subnet.bastion.address_prefixes[0]
  }
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value = {
    compute = azurerm_network_security_group.compute.id
    data    = azurerm_network_security_group.data.id
  }
}
