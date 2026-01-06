# -----------------------------------------------------------------------------
# STAGING ENVIRONMENT CONFIGURATION
# -----------------------------------------------------------------------------

environment  = "staging"
location     = "eastus"
project_name = "workload"
owner        = "platform-team"
cost_center  = "engineering"

# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------

vnet_address_space = "10.200.0.0/16"

subnet_prefixes = {
  compute          = "10.200.1.0/24"
  data             = "10.200.2.0/24"
  private_endpoint = "10.200.3.0/24"
  bastion          = "10.200.255.0/26"
}

enable_private_endpoints = true

# -----------------------------------------------------------------------------
# COMPUTE
# -----------------------------------------------------------------------------

vm_count           = 1
vm_size            = "Standard_D4s_v5"
vm_os_disk_size_gb = 128

# Auto-shutdown at 8 PM UTC
enable_auto_shutdown = true
auto_shutdown_time   = "2000"

# -----------------------------------------------------------------------------
# SECURITY
# -----------------------------------------------------------------------------

keyvault_sku                        = "premium"
keyvault_soft_delete_days           = 30
enable_purge_protection             = false
keyvault_network_acl_default_action = "Deny"

# -----------------------------------------------------------------------------
# BASTION
# -----------------------------------------------------------------------------

enable_bastion      = true
bastion_sku         = "Standard"
bastion_scale_units = 2

# -----------------------------------------------------------------------------
# MONITORING
# -----------------------------------------------------------------------------

log_retention_days          = 60
enable_application_insights = true

# -----------------------------------------------------------------------------
# BACKUP / DR
# -----------------------------------------------------------------------------

backup_retention_days = 14
secondary_location    = null
