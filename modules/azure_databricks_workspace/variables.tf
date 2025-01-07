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
  default     = "NoAzureServiceRules"
}

variable "tags" {
  description = "Tags to apply to the workspace"
  type        = map(string)
  default     = {}
}

variable "no_public_ip" {
  description = "Specifies whether to deploy Azure Databricks workspace with no public IP"
  type        = bool
  default     = true
}

variable "vnet_id" {
  description = "The ID of the Virtual Network where the Databricks workspace should be deployed"
  type        = string
  default     = null
}

variable "private_subnet_name" {
  description = "The name of the Private Subnet within the Virtual Network"
  type        = string
  default     = null
}

variable "private_allowed_cidr" {
  description = "The CIDR block to allow traffic from the private subnet"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the Public Subnet within the Virtual Network"
  type        = string
  default     = null
}

variable "public_allowed_cidr" {
  description = "The CIDR block to allow traffic from the public subnet"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint should be created"
  type        = string
  default     = null
}
