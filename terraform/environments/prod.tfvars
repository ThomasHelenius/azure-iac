# -----------------------------------------------------------------------------
# PRODUCTION ENVIRONMENT CONFIGURATION
# -----------------------------------------------------------------------------

environment  = "prod"
location     = "eastus"
project_name = "workload"
owner        = "platform-team"
cost_center  = "engineering"

# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------

vnet_address_space = "10.0.0.0/16"

subnet_prefixes = {
  compute          = "10.0.1.0/24"
  data             = "10.0.2.0/24"
  private_endpoint = "10.0.3.0/24"
  bastion          = "10.0.255.0/26"
}

enable_private_endpoints = true

# -----------------------------------------------------------------------------
# COMPUTE
# -----------------------------------------------------------------------------

vm_count           = 2
vm_size            = "Standard_E8ds_v5"
vm_os_disk_size_gb = 256

# No auto-shutdown in production
enable_auto_shutdown = false
auto_shutdown_time   = "2000"

# -----------------------------------------------------------------------------
# SECURITY
# -----------------------------------------------------------------------------

keyvault_sku                        = "premium"
keyvault_soft_delete_days           = 90
enable_purge_protection             = true
keyvault_network_acl_default_action = "Deny"

# -----------------------------------------------------------------------------
# BASTION
# -----------------------------------------------------------------------------

enable_bastion      = true
bastion_sku         = "Standard"
bastion_scale_units = 4

# -----------------------------------------------------------------------------
# MONITORING
# -----------------------------------------------------------------------------

log_retention_days          = 90
enable_application_insights = true

# -----------------------------------------------------------------------------
# BACKUP / DR
# -----------------------------------------------------------------------------

backup_retention_days = 30
secondary_location    = "westus2"
