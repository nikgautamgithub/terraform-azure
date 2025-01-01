variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Key Vault will be created."
  type        = string
}

variable "location" {
  description = "The location/region where the Key Vault will be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Key Vault (Standard or Premium)."
  type        = string
  default     = "standard"
}

variable "tenant_id" {
  description = "The tenant ID of the Azure Active Directory that manages the Key Vault."
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the ACR"
  type        = map(string)
  default     = {}
}
