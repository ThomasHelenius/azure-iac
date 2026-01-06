# -----------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be provided when applying the configuration
# -----------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"

  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "Location must be a valid Azure region identifier."
  }
}

variable "vm_admin_username" {
  type        = string
  description = "Administrator username for virtual machines"

  validation {
    condition     = length(var.vm_admin_username) >= 1 && length(var.vm_admin_username) <= 64
    error_message = "Admin username must be between 1 and 64 characters."
  }

  validation {
    condition     = !contains(["administrator", "admin", "user", "user1", "test", "root", "guest"], lower(var.vm_admin_username))
    error_message = "Admin username cannot be a reserved name."
  }
}

variable "vm_ssh_public_key" {
  type        = string
  description = "SSH public key for VM authentication"
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa ", var.vm_ssh_public_key)) || can(regex("^ssh-ed25519 ", var.vm_ssh_public_key))
    error_message = "SSH public key must be in valid OpenSSH format (ssh-rsa or ssh-ed25519)."
  }
}

# -----------------------------------------------------------------------------
# PROJECT CONFIGURATION
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"
  default     = "workload"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,10}$", var.project_name))
    error_message = "Project name must be 2-11 lowercase alphanumeric characters, starting with a letter."
  }
}

variable "owner" {
  type        = string
  description = "Owner identifier for tagging"
  default     = "platform-team"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing allocation"
  default     = "engineering"
}

# -----------------------------------------------------------------------------
# NETWORKING CONFIGURATION
# -----------------------------------------------------------------------------

variable "vnet_address_space" {
  type        = string
  description = "Address space for the virtual network (CIDR notation)"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "VNet address space must be a valid CIDR block."
  }
}

variable "subnet_prefixes" {
  type = object({
    compute          = string
    data             = string
    private_endpoint = string
    bastion          = string
  })
  description = "CIDR prefixes for each subnet"
  default = {
    compute          = "10.0.1.0/24"
    data             = "10.0.2.0/24"
    private_endpoint = "10.0.3.0/24"
    bastion          = "10.0.255.0/26"
  }

  validation {
    condition     = can(cidrhost(var.subnet_prefixes.bastion, 0)) && tonumber(split("/", var.subnet_prefixes.bastion)[1]) <= 26
    error_message = "Bastion subnet must be at least /26 as required by Azure."
  }
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Enable private endpoints for PaaS services"
  default     = false
}

# -----------------------------------------------------------------------------
# COMPUTE CONFIGURATION
# -----------------------------------------------------------------------------

variable "vm_count" {
  type        = number
  description = "Number of virtual machines to deploy"
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_D4s_v5"
}

variable "vm_os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB"
  default     = 128

  validation {
    condition     = var.vm_os_disk_size_gb >= 30 && var.vm_os_disk_size_gb <= 4096
    error_message = "OS disk size must be between 30 and 4096 GB."
  }
}

variable "enable_auto_shutdown" {
  type        = bool
  description = "Enable auto-shutdown for VMs"
  default     = true
}

variable "auto_shutdown_time" {
  type        = string
  description = "Daily auto-shutdown time in HH:MM format (UTC)"
  default     = "2000"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3])[0-5][0-9]$", var.auto_shutdown_time))
    error_message = "Auto-shutdown time must be in HHMM format (e.g., 2000 for 8:00 PM)."
  }
}

# -----------------------------------------------------------------------------
# SECURITY CONFIGURATION
# -----------------------------------------------------------------------------

variable "keyvault_sku" {
  type        = string
  description = "Key Vault SKU (standard or premium)"
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium"], var.keyvault_sku)
    error_message = "Key Vault SKU must be 'standard' or 'premium'."
  }
}

variable "keyvault_soft_delete_days" {
  type        = number
  description = "Number of days to retain soft-deleted Key Vault items"
  default     = 7

  validation {
    condition     = var.keyvault_soft_delete_days >= 7 && var.keyvault_soft_delete_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "enable_purge_protection" {
  type        = bool
  description = "Enable purge protection for Key Vault"
  default     = false
}

variable "keyvault_network_acl_default_action" {
  type        = string
  description = "Default action for Key Vault network ACLs"
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.keyvault_network_acl_default_action)
    error_message = "Network ACL default action must be 'Allow' or 'Deny'."
  }
}

# -----------------------------------------------------------------------------
# BASTION CONFIGURATION
# -----------------------------------------------------------------------------

variable "enable_bastion" {
  type        = bool
  description = "Enable Azure Bastion deployment"
  default     = true
}

variable "bastion_sku" {
  type        = string
  description = "Azure Bastion SKU (Basic or Standard)"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "Bastion SKU must be 'Basic' or 'Standard'."
  }
}

variable "bastion_scale_units" {
  type        = number
  description = "Number of scale units for Bastion (Standard SKU only)"
  default     = 2

  validation {
    condition     = var.bastion_scale_units >= 2 && var.bastion_scale_units <= 50
    error_message = "Bastion scale units must be between 2 and 50."
  }
}

# -----------------------------------------------------------------------------
# MONITORING CONFIGURATION
# -----------------------------------------------------------------------------

variable "log_retention_days" {
  type        = number
  description = "Log Analytics workspace retention in days"
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "enable_application_insights" {
  type        = bool
  description = "Enable Application Insights deployment"
  default     = true
}

# -----------------------------------------------------------------------------
# DISASTER RECOVERY
# -----------------------------------------------------------------------------

variable "secondary_location" {
  type        = string
  description = "Secondary Azure region for disaster recovery (optional)"
  default     = null
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention period in days"
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 7 and 365 days."
  }
}
