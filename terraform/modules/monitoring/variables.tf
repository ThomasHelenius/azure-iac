# -----------------------------------------------------------------------------
# MONITORING MODULE VARIABLES
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "log_analytics_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
}

variable "app_insights_name" {
  type        = string
  description = "Name of the Application Insights instance"
}

variable "retention_days" {
  type        = number
  description = "Data retention period in days"
  default     = 30

  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "enable_application_insights" {
  type        = bool
  description = "Enable Application Insights"
  default     = true
}

variable "daily_data_cap_gb" {
  type        = number
  description = "Daily data cap for Application Insights in GB (0 = unlimited)"
  default     = 0
}

variable "enable_container_insights" {
  type        = bool
  description = "Enable Container Insights solution"
  default     = false
}

variable "enable_security_solution" {
  type        = bool
  description = "Enable Security solution"
  default     = false
}

variable "enable_alerts" {
  type        = bool
  description = "Enable metric alerts"
  default     = false
}

variable "alert_email_addresses" {
  type        = list(string)
  description = "Email addresses for alert notifications"
  default     = []
}

variable "vm_resource_ids" {
  type        = list(string)
  description = "VM resource IDs for metric alerts"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
