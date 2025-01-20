variable "name" {
  description = "Name of the SendGrid resource"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where SendGrid will be deployed"
  type        = string
}

variable "region" {
  description = "Azure region where the SendGrid account will be created"
  type        = string
}

variable "plan" {
  description = "SendGrid plan type"
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
