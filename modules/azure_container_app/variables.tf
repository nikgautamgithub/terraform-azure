variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "container_app_name" {
  type        = string
  description = "Name of the Container App"
}

variable "location" {
  type        = string
  description = "Azure region for the Container App"
}

/*
==================================
==  Container App Environment   ==
==================================
*/

variable "container_app_env_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy"
  default     = false
}

variable "logs_destination" {
  type        = string
  description = "Destination for logs"
  default     = null
  validation {
    condition     = contains(["log-analytics", "azure-monitor"], var.logs_destination)
    error_message = "Logs destination must be log-analytics or azure-monitor."
  }
}

variable "workload_profile" {
  type        = string
  description = "Workload profile for the Container App"
  validation {
    condition     = contains(["D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], var.workload_profile)
    error_message = "Workload profile for the Container must be one of D4, D8, D16, D32, E4, E8, E16 and E32"
  }
}

variable "workload_profile_max_count" {
  type        = number
  description = "Maximum count for the workload profile"
  default     = null
}

variable "workload_profile_min_count" {
  type        = number
  description = "Minimum count for the workload profile"
  default     = null
}

/*
==================================
==  Container App  ==
==================================
*/

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
}

variable "registry_server" {
  type        = string
  description = "Container registry server"
}

variable "image" {
  type        = string
  description = "Container image name"
}

variable "image_tag" {
  type        = string
  description = "Container image tag"
}

variable "cpu" {
  type        = string
  description = "CPU allocation"
  validation {
    condition     = contains(["0.25", "0.5", "0.75", "1.0", "1.25", "1.5", "1.75", "2.0"], var.cpu)
    error_message = "CPU must be one of 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, and 2.0"
  }
}

variable "memory" {
  type        = string
  description = "Memory allocation"
  validation {
    condition     = contains(["0.5Gi", "1Gi", "1.5Gi", "2Gi", "2.5Gi", "3Gi", "3.5Gi", "4Gi"], var.memory)
    error_message = "Memory must be one of 0.5Gi, 1Gi, 1.5Gi, 2Gi, 2.5Gi, 3Gi, 3.5Gi and 4Gi"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags for the Container App"
  default     = {}
}
