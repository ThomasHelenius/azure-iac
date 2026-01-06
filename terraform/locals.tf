# -----------------------------------------------------------------------------
# LOCAL VALUES
# Computed values and naming conventions used throughout the configuration
# -----------------------------------------------------------------------------

locals {
  # -----------------------------------------------------------------------------
  # NAMING CONVENTION
  # Pattern: {resource-type}-{project}-{component}-{environment}
  # -----------------------------------------------------------------------------

  name_prefix = var.project_name
  name_suffix = var.environment

  # Resource group names
  resource_groups = {
    network  = "rg-${local.name_prefix}-network-${local.name_suffix}"
    compute  = "rg-${local.name_prefix}-compute-${local.name_suffix}"
    security = "rg-${local.name_prefix}-security-${local.name_suffix}"
    monitor  = "rg-${local.name_prefix}-monitor-${local.name_suffix}"
  }

  # Network resource names
  vnet_name = "vnet-${local.name_prefix}-${local.name_suffix}"

  subnet_names = {
    compute          = "snet-compute-${local.name_prefix}-${local.name_suffix}"
    data             = "snet-data-${local.name_prefix}-${local.name_suffix}"
    private_endpoint = "snet-pe-${local.name_prefix}-${local.name_suffix}"
    bastion          = "AzureBastionSubnet" # Azure requires this exact name
  }

  nsg_names = {
    compute = "nsg-compute-${local.name_prefix}-${local.name_suffix}"
    data    = "nsg-data-${local.name_prefix}-${local.name_suffix}"
  }

  # Compute resource names
  vm_name_prefix  = "vm-${local.name_prefix}-${local.name_suffix}"
  nic_name_prefix = "nic-${local.name_prefix}-${local.name_suffix}"

  # Security resource names
  keyvault_name = "kv-${local.name_prefix}-${local.name_suffix}"

  # Bastion resource names
  bastion_name     = "bas-${local.name_prefix}-${local.name_suffix}"
  bastion_pip_name = "pip-bas-${local.name_prefix}-${local.name_suffix}"

  # Monitoring resource names
  log_analytics_name = "log-${local.name_prefix}-${local.name_suffix}"
  app_insights_name  = "appi-${local.name_prefix}-${local.name_suffix}"

  # -----------------------------------------------------------------------------
  # COMMON TAGS
  # Applied to all resources for cost tracking and governance
  # -----------------------------------------------------------------------------

  common_tags = {
    Project            = var.project_name
    Environment        = var.environment
    ManagedBy          = "Terraform"
    Owner              = var.owner
    CostCenter         = "${var.cost_center}-${var.environment}"
    DataClassification = local.data_classification
  }

  # Environment-specific data classification
  data_classification = var.environment == "prod" ? "Restricted" : "Confidential"

  # -----------------------------------------------------------------------------
  # ENVIRONMENT-SPECIFIC SETTINGS
  # -----------------------------------------------------------------------------

  # Determine if this is a production environment
  is_production = var.environment == "prod"

  # High availability settings
  enable_high_availability = local.is_production

  # Zone redundancy for production
  availability_zones = local.is_production ? ["1", "2", "3"] : ["1"]
}
