variable "name" {
  description = "Name of the Logic App"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "pricing_plan" {
  type        = string
  description = "Pricing plan SKU"
  default     = "WS1" # Default pricing plan
  validation {
    condition     = contains(["WS1", "WS2", "WS3"], var.pricing_plan)
    error_message = "Pricing plan must be one of: WS1, WS2, WS3"
  }
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "vnet_name" {
  description = "Name of the VNet"
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  type        = string
  default     = null
}

variable "logic_app_subnet_name" {
  description = "Name of the logic app subnet"
  type        = string
  default     = null
}

variable "inbound_subnet_name" {
  description = "Name of the inbound subnet"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "enable_application_insights" {
  type        = bool
  default     = false
  description = "Enable Application Insights"
}
