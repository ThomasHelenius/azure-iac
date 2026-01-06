# -----------------------------------------------------------------------------
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# -----------------------------------------------------------------------------

environment  = "dev"
location     = "eastus"
project_name = "workload"
owner        = "platform-team"
cost_center  = "engineering"

# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------

vnet_address_space = "10.100.0.0/16"

subnet_prefixes = {
  compute          = "10.100.1.0/24"
  data             = "10.100.2.0/24"
  private_endpoint = "10.100.3.0/24"
  bastion          = "10.100.255.0/26"
}

enable_private_endpoints = false

# -----------------------------------------------------------------------------
# COMPUTE
# -----------------------------------------------------------------------------

vm_count           = 1
vm_size            = "Standard_D4s_v5"
vm_os_disk_size_gb = 128

# Auto-shutdown at 8 PM UTC to save costs
enable_auto_shutdown = true
auto_shutdown_time   = "2000"

# -----------------------------------------------------------------------------
# SECURITY
# -----------------------------------------------------------------------------

keyvault_sku                        = "premium"
keyvault_soft_delete_days           = 7
enable_purge_protection             = false
keyvault_network_acl_default_action = "Allow"

# -----------------------------------------------------------------------------
# BASTION
# -----------------------------------------------------------------------------

enable_bastion      = true
bastion_sku         = "Basic"
bastion_scale_units = 2

# -----------------------------------------------------------------------------
# MONITORING
# -----------------------------------------------------------------------------

log_retention_days          = 30
enable_application_insights = true

# -----------------------------------------------------------------------------
# BACKUP / DR
# -----------------------------------------------------------------------------

backup_retention_days = 7
secondary_location    = null
