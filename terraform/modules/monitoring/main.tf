# -----------------------------------------------------------------------------
# MONITORING MODULE
# Creates Log Analytics workspace and Application Insights
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# LOG ANALYTICS WORKSPACE
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days

  # Enable features
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = var.tags
}

# -----------------------------------------------------------------------------
# LOG ANALYTICS SOLUTIONS
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_solution" "container_insights" {
  count = var.enable_container_insights ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "security" {
  count = var.enable_security_solution ? 1 : 0

  solution_name         = "Security"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# APPLICATION INSIGHTS
# -----------------------------------------------------------------------------

resource "azurerm_application_insights" "main" {
  count = var.enable_application_insights ? 1 : 0

  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  retention_in_days = var.retention_days

  # Disable daily cap for production
  daily_data_cap_in_gb = var.daily_data_cap_gb

  tags = var.tags
}

# -----------------------------------------------------------------------------
# ACTION GROUP FOR ALERTS
# -----------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "critical" {
  count = var.enable_alerts && length(var.alert_email_addresses) > 0 ? 1 : 0

  name                = "ag-${var.log_analytics_name}-critical"
  resource_group_name = var.resource_group_name
  short_name          = "Critical"

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# METRIC ALERTS
# -----------------------------------------------------------------------------

# Alert for high CPU usage on VMs
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  count = var.enable_alerts ? 1 : 0

  name                = "alert-vm-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "Alert when CPU usage exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  dynamic "action" {
    for_each = var.enable_alerts && length(var.alert_email_addresses) > 0 ? [1] : []
    content {
      action_group_id = azurerm_monitor_action_group.critical[0].id
    }
  }

  tags = var.tags
}
