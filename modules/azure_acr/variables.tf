# modules/azure_acr/variables.tf
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the ACR will be created"
  type        = string
}

variable "sku" {
  description = "SKU of the ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Enable admin user for the ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to be applied to the ACR"
  type        = map(string)
  default     = {}
}
