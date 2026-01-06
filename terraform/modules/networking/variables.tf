# -----------------------------------------------------------------------------
# NETWORKING MODULE VARIABLES
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "vnet_address_space" {
  type        = string
  description = "Address space for the virtual network (CIDR notation)"
}

variable "subnet_names" {
  type = object({
    compute          = string
    data             = string
    private_endpoint = string
    bastion          = string
  })
  description = "Names for each subnet"
}

variable "subnet_prefixes" {
  type = object({
    compute          = string
    data             = string
    private_endpoint = string
    bastion          = string
  })
  description = "CIDR prefixes for each subnet"
}

variable "nsg_names" {
  type = object({
    compute = string
    data    = string
  })
  description = "Names for network security groups"
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Enable private endpoint subnet configuration"
  default     = false
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
