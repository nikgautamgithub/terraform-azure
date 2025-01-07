variable "workspace_name" {
  description = "Name of the Databricks workspace"
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

variable "sku" {
  description = "The SKU to use for the Databricks workspace"
  type        = string
}

variable "network_security_group_rules" {
  description = "Specifies whether to deploy network security group rules for the Databricks workspace"
  type        = string
  default     = "NoAzureDatabricksRules"
}

variable "tags" {
  description = "Tags to apply to the workspace"
  type        = map(string)
  default     = {}
}

variable "vnet_id" {
  description = "The ID of the Virtual Network where the Databricks workspace should be deployed"
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the Private Subnet within the Virtual Network"
  type        = string
}

variable "private_subnet_nsg_id" {
  description = "The ID of the Network Security Group associated with the Private Subnet"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the Public Subnet within the Virtual Network"
  type        = string
}

variable "public_subnet_nsg_id" {
  description = "The ID of the Network Security Group associated with the Public Subnet"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint should be created"
  type        = string
}
