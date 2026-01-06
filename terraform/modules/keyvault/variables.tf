# -----------------------------------------------------------------------------
# KEY VAULT MODULE VARIABLES
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "keyvault_name" {
  type        = string
  description = "Name of the Key Vault"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.keyvault_name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric and hyphens, starting with a letter."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU for Key Vault (standard or premium)"
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted items"
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days."
  }
}

variable "enable_purge_protection" {
  type        = bool
  description = "Enable purge protection (cannot be disabled once enabled)"
  default     = false
}

variable "network_acl_default_action" {
  type        = string
  description = "Default action for network ACLs"
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acl_default_action)
    error_message = "Default action must be 'Allow' or 'Deny'."
  }
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of IP ranges allowed to access Key Vault"
  default     = []
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs allowed to access Key Vault"
  default     = []
}

variable "admin_object_ids" {
  type        = list(string)
  description = "Object IDs to grant Key Vault Administrator role"
  default     = []
}

variable "secrets_user_object_ids" {
  type        = list(string)
  description = "Object IDs to grant Key Vault Secrets User role"
  default     = []
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable private endpoint for Key Vault"
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint"
  default     = null
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network ID for private DNS zone link"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of Log Analytics workspace for diagnostics"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
