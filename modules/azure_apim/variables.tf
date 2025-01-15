variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "region" {
  type        = string
  description = "Azure region location"
}

variable "apim_name" {
  type        = string
  description = "Name of the API Management service"
}

variable "publisher_name" {
  type        = string
  description = "Publisher name for the APIM instance"
}

variable "publisher_email" {
  type        = string
  description = "Publisher email for the APIM instance"
}

variable "sku_name" {
  type        = string
  description = "SKU of the API Management service"
}

variable "zones" {
  type        = list(string)
  description = "A list of availability zones. Only used when sku_name is Premium"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the APIM instance"
  default     = {}
}

variable "existing_application_insights" {
  type        = string
  description = "Existing Application Insights instance details"
}

variable "connectivity_type" {
  type        = string
  description = "Type of network connectivity. Possible values are: 'None', 'Virtual Network', 'Private Endpoint'"
  default     = "None"
  validation {
    condition     = contains(["None", "Virtual Network", "Private Endpoint"], var.connectivity_type)
    error_message = "Allowed values for connectivity_type are 'None', 'VirtualNetwork', or 'PrivateEndpoint'"
  }
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to be used for VNet integration or Private Endpoint"
  default     = null
}

variable "subresource" {
  type        = string
  description = "Subresource name for private endpoint"
  default     = null
}
