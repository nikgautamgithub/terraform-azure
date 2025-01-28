variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "location" {
  description = "Azure region where the SQL Server will be created"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "admin_username_secret_name" {
  description = "Name of the admin username secret in Key Vault"
  type        = string
}

variable "admin_password_secret_name" {
  description = "Name of the admin password secret in Key Vault"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the SQL Server"
  type        = map(string)
  default     = {}
}
