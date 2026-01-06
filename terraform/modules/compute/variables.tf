# -----------------------------------------------------------------------------
# COMPUTE MODULE VARIABLES
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "vm_name_prefix" {
  type        = string
  description = "Prefix for virtual machine names"
}

variable "nic_name_prefix" {
  type        = string
  description = "Prefix for network interface names"
}

variable "vm_count" {
  type        = number
  description = "Number of virtual machines to create"
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machines"
  default     = "Standard_D4s_v5"
}

variable "os_disk_size_gb" {
  type        = number
  description = "Size of the OS disk in GB"
  default     = 128
}

variable "admin_username" {
  type        = string
  description = "Administrator username for VMs"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for authentication"
  sensitive   = true
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet for VM network interfaces"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for VM distribution"
  default     = []
}

variable "enable_auto_shutdown" {
  type        = bool
  description = "Enable auto-shutdown schedule"
  default     = true
}

variable "auto_shutdown_time" {
  type        = string
  description = "Daily auto-shutdown time in HHMM format (UTC)"
  default     = "2000"
}

variable "keyvault_id" {
  type        = string
  description = "ID of Key Vault for VM access assignment"
  default     = null
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of Log Analytics workspace for VM monitoring"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
