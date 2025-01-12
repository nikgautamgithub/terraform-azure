variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "region" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters long and may contain numbers and lowercase letters only."
  }
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the private endpoint will be created"
}

variable "private_endpoint_subresource_name" {
  type        = list(string)
  description = "List of subresource names for private endpoint (e.g., ['blob', 'file', 'queue', 'table'])"
  default     = ["blob"]
}

variable "account_tier" {
  type        = string
  description = "Performance tier (Standard or Premium)"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Type of replication to use. Options: LRS, GRS, RAGRS"
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS"], var.account_replication_type)
    error_message = "Account replication type must be either LRS, GRS, or RAGRS."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
