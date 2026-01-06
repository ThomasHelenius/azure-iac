# -----------------------------------------------------------------------------
# NETWORKING MODULE
# Creates VNet, subnets, NSGs, and network security rules
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# VIRTUAL NETWORK
# -----------------------------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

# -----------------------------------------------------------------------------
# SUBNETS
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "compute" {
  name                 = var.subnet_names.compute
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes.compute]

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "data" {
  name                 = var.subnet_names.data
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes.data]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = var.subnet_names.private_endpoint
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes.private_endpoint]

  # Required for private endpoints
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "bastion" {
  name                 = var.subnet_names.bastion # Must be "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes.bastion]
}

# -----------------------------------------------------------------------------
# NETWORK SECURITY GROUPS
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "compute" {
  name                = var.nsg_names.compute
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_group" "data" {
  name                = var.nsg_names.data
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# COMPUTE SUBNET NSG RULES
# -----------------------------------------------------------------------------

# Allow SSH from Bastion subnet only
resource "azurerm_network_security_rule" "compute_allow_ssh_from_bastion" {
  name                        = "AllowSSHFromBastion"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.subnet_prefixes.bastion
  destination_address_prefix  = var.subnet_prefixes.compute
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Allow HTTPS from VNet
resource "azurerm_network_security_rule" "compute_allow_https_from_vnet" {
  name                        = "AllowHTTPSFromVNet"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = var.subnet_prefixes.compute
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Allow HTTP from VNet
resource "azurerm_network_security_rule" "compute_allow_http_from_vnet" {
  name                        = "AllowHTTPFromVNet"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = var.subnet_prefixes.compute
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Allow custom application ports from VNet (e.g., webhook endpoints)
resource "azurerm_network_security_rule" "compute_allow_app_ports_from_vnet" {
  name                        = "AllowAppPortsFromVNet"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5678", "8080", "3000"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = var.subnet_prefixes.compute
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Deny all other inbound from internet
resource "azurerm_network_security_rule" "compute_deny_internet_inbound" {
  name                        = "DenyInternetInbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Allow outbound to data subnet
resource "azurerm_network_security_rule" "compute_allow_outbound_to_data" {
  name                        = "AllowOutboundToData"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5432", "6379"]
  source_address_prefix       = var.subnet_prefixes.compute
  destination_address_prefix  = var.subnet_prefixes.data
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# Allow outbound HTTPS to internet (for external APIs, updates)
resource "azurerm_network_security_rule" "compute_allow_https_outbound" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.subnet_prefixes.compute
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.compute.name
}

# -----------------------------------------------------------------------------
# DATA SUBNET NSG RULES
# -----------------------------------------------------------------------------

# Allow PostgreSQL from compute subnet only
resource "azurerm_network_security_rule" "data_allow_postgresql_from_compute" {
  name                        = "AllowPostgreSQLFromCompute"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = var.subnet_prefixes.compute
  destination_address_prefix  = var.subnet_prefixes.data
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

# Allow Redis from compute subnet only
resource "azurerm_network_security_rule" "data_allow_redis_from_compute" {
  name                        = "AllowRedisFromCompute"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6379"
  source_address_prefix       = var.subnet_prefixes.compute
  destination_address_prefix  = var.subnet_prefixes.data
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

# Deny all other inbound
resource "azurerm_network_security_rule" "data_deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

# -----------------------------------------------------------------------------
# NSG ASSOCIATIONS
# -----------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "compute" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.compute.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# -----------------------------------------------------------------------------
# DIAGNOSTIC SETTINGS
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.vnet_name}"
  target_resource_id         = azurerm_virtual_network.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_compute" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.nsg_names.compute}"
  target_resource_id         = azurerm_network_security_group.compute.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_data" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.nsg_names.data}"
  target_resource_id         = azurerm_network_security_group.data.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
