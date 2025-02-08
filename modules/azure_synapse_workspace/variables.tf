variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "workspace_name" {
  type        = string
  description = "Name of the Synapse Workspace"
}

variable "location" {
  type        = string
  description = "Azure region for the Synapse Workspace"
}

variable "account_name" {
  type        = string
  description = "Name of the Data Lake Storage Account"
}

variable "filesystem_name" {
  type        = string
  description = "Name of the Data Lake File System"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Synapse Workspace"
  default     = {}
}
