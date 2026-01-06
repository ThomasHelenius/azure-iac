# -----------------------------------------------------------------------------
# ROOT MODULE
# Orchestrates deployment of all infrastructure modules
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

# -----------------------------------------------------------------------------
# RESOURCE GROUPS
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "network" {
  name     = local.resource_groups.network
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "compute" {
  name     = local.resource_groups.compute
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "security" {
  name     = local.resource_groups.security
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "monitor" {
  name     = local.resource_groups.monitor
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# MONITORING MODULE
# Deploy first as other modules may reference Log Analytics workspace
# -----------------------------------------------------------------------------

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location

  log_analytics_name          = local.log_analytics_name
  app_insights_name           = local.app_insights_name
  retention_days              = var.log_retention_days
  enable_application_insights = var.enable_application_insights

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# NETWORKING MODULE
# -----------------------------------------------------------------------------

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  vnet_name          = local.vnet_name
  vnet_address_space = var.vnet_address_space

  subnet_names    = local.subnet_names
  subnet_prefixes = var.subnet_prefixes

  nsg_names = local.nsg_names

  enable_private_endpoints = var.enable_private_endpoints

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# KEY VAULT MODULE
# -----------------------------------------------------------------------------

module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location

  keyvault_name              = local.keyvault_name
  sku_name                   = var.keyvault_sku
  soft_delete_retention_days = var.keyvault_soft_delete_days
  enable_purge_protection    = var.enable_purge_protection
  network_acl_default_action = var.keyvault_network_acl_default_action
  enable_private_endpoint    = var.enable_private_endpoints
  private_endpoint_subnet_id = module.networking.subnet_ids["private_endpoint"]
  virtual_network_id         = module.networking.vnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Grant deploying identity admin access
  admin_object_ids = [data.azurerm_client_config.current.object_id]

  tags = local.common_tags

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# COMPUTE MODULE
# -----------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location

  vm_name_prefix       = local.vm_name_prefix
  nic_name_prefix      = local.nic_name_prefix
  vm_count             = var.vm_count
  vm_size              = var.vm_size
  os_disk_size_gb      = var.vm_os_disk_size_gb
  admin_username       = var.vm_admin_username
  ssh_public_key       = var.vm_ssh_public_key
  subnet_id            = module.networking.subnet_ids["compute"]
  enable_auto_shutdown = var.enable_auto_shutdown
  auto_shutdown_time   = var.auto_shutdown_time
  availability_zones   = local.availability_zones

  keyvault_id                = module.keyvault.keyvault_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [module.networking, module.keyvault]
}

# -----------------------------------------------------------------------------
# BASTION MODULE
# -----------------------------------------------------------------------------

module "bastion" {
  source = "./modules/bastion"

  count = var.enable_bastion ? 1 : 0

  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  bastion_name   = local.bastion_name
  public_ip_name = local.bastion_pip_name
  subnet_id      = module.networking.subnet_ids["bastion"]
  sku            = var.bastion_sku
  scale_units    = var.bastion_scale_units

  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  tags = local.common_tags

  depends_on = [module.networking]
}
