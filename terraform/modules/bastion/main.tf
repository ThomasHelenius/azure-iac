# -----------------------------------------------------------------------------
# BASTION MODULE
# Creates Azure Bastion for secure VM access without public IPs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# PUBLIC IP FOR BASTION
# -----------------------------------------------------------------------------

resource "azurerm_public_ip" "bastion" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

# -----------------------------------------------------------------------------
# AZURE BASTION HOST
# -----------------------------------------------------------------------------

resource "azurerm_bastion_host" "main" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.sku == "Standard" ? var.scale_units : null

  # Security settings
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.sku == "Standard" ? var.file_copy_enabled : false
  shareable_link_enabled = false # Disabled for security
  tunneling_enabled      = var.sku == "Standard" ? var.tunneling_enabled : false
  ip_connect_enabled     = false # Disabled for security

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# DIAGNOSTIC SETTINGS
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.bastion_name}"
  target_resource_id         = azurerm_bastion_host.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "bastion_pip" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.public_ip_name}"
  target_resource_id         = azurerm_public_ip.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  enabled_log {
    category = "DDoSMitigationReports"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
