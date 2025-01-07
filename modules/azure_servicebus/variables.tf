variable "namespace_name" {
  description = "The name of the Service Bus namespace."
  type        = string
}

variable "region" {
  description = "The Azure region for the Service Bus."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku" {
  description = "The SKU for the Service Bus namespace."
  type        = string
  default     = "Standard"
}

variable "minimum_tls_version" {
  description = "The minimum supported TLS version. Valid values: 1.0, 1.1, 1.2"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Service Bus."
  type        = map(string)
  default     = {}
}
