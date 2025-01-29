variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
}

variable "server_id" {
  description = "ID of the existing SQL server"
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet"
  type        = string
}

variable "workload_environment" {
  description = "Environment type for the workload"
  type        = string
}

variable "compute_storage" {
  description = "Compute and storage configuration"
  type        = string
}

variable "redundancy" {
  description = "Redundancy configuration for the database"
  type        = string
  validation {
    condition     = contains(["Local", "Zone", "Geo", "GeoZone"], var.redundancy)
    error_message = "Storage account type must be one of: Local, Zone, Geo, or GeoZone"
  }
}

variable "tags" {
  description = "Map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
