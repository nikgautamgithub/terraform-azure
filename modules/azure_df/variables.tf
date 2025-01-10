variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "region" {
  type        = string
  description = "Azure region where the resources will be created"
}

variable "data_factory_name" {
  type        = string
  description = "Name of the Azure Data Factory instance"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to all resources"
  default     = {}
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the private endpoint will be created"
}

variable "private_endpoint_name" {
  type        = string
  description = "Name of the private endpoint"
  default     = null
}

variable "subresource" {
  type        = string
  description = "Name of the private subresource"
}
