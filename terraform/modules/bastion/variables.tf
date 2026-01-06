# -----------------------------------------------------------------------------
# BASTION MODULE VARIABLES
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "bastion_name" {
  type        = string
  description = "Name of the Bastion host"
}

variable "public_ip_name" {
  type        = string
  description = "Name of the public IP for Bastion"
}

variable "subnet_id" {
  type        = string
  description = "ID of the AzureBastionSubnet"
}

variable "sku" {
  type        = string
  description = "SKU for Azure Bastion (Basic or Standard)"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be 'Basic' or 'Standard'."
  }
}

variable "scale_units" {
  type        = number
  description = "Number of scale units for Standard SKU"
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be between 2 and 50."
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the public IP"
  default     = ["1", "2", "3"]
}

variable "copy_paste_enabled" {
  type        = bool
  description = "Enable copy/paste functionality"
  default     = true
}

variable "file_copy_enabled" {
  type        = bool
  description = "Enable file copy functionality (Standard SKU only)"
  default     = true
}

variable "tunneling_enabled" {
  type        = bool
  description = "Enable tunneling for native client (Standard SKU only)"
  default     = true
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
