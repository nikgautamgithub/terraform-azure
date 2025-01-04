variable "identity_name" {
  description = "The name of the User Assigned Managed Identity."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the User Assigned Managed Identity will be created."
  type        = string
}

variable "region" {
  description = "The location/region where the User Assigned Managed Identity will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the User Assigned Managed Identity."
  type        = map(string)
  default     = {}
}
