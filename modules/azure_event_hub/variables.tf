variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "namespace_name" {
  description = "Name of the Event Hub Namespace"
  type        = string
}

variable "location" {
  description = "Azure region where the Event Hub will be created"
  type        = string
}

variable "pricing_tier" {
  description = "Pricing tier for the Event Hub Namespace (Basic, Standard, or Premium)"
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.pricing_tier)
    error_message = "Pricing tier must be one of: Basic, Standard, or Premium"
  }
}

variable "throughput_units" {
  description = "Throughput units for the Event Hub Namespace"
  type        = number
  validation {
    condition     = var.throughput_units >= 1 && var.throughput_units <= 20
    error_message = "Throughput units must be between 1 and 20"
  }
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be applied to the Event Hub Namespace"
  type        = map(string)
  default     = {}
}
