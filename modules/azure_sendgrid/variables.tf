variable "resource_group_name" {
  description = "Name of the resource group where SendGrid will be deployed"
  type        = string
}

variable "name" {
  description = "Name of the SendGrid resource"
  type        = string
}

variable "region" {
  description = "The location/region where the Key Vault will be created"
  type        = string
}

variable "plan" {
  description = "SendGrid plan type"
  type        = string
}

variable "recurring_billing" {
  description = "Enable or disable recurring billing"
  type        = bool
}

variable "tags" {
  description = "Map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
