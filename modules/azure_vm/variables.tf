variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "os_type" {
  type = string
}

variable "os_image" {
  type = string
}

variable "os_disk_type" {
  type = string
}

variable "os_disk_size" {
  description = "Size of the OS disk in GB"
  type        = number
}

variable "zones" {
  description = "Availability zone for the VM"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.zones) <= 3
    error_message = "Maximum 3 availability zones are supported."
  }
}

variable "ports" {
  description = "List of ports to open for inbound traffic"
  type        = list(string)
  default     = []
}

variable "nsg_name" {
  description = "Names of the Network Security Groups for the VM"
  type        = string
}

variable "vnet_name" {
  description = "Names of the Virtual Networks for the VM"
  type        = string
}

variable "subnet_name" {
  description = "Names of the Subnets within the VNets"
  type        = string
}

variable "public_ip_required" {
  description = "Flag to indicate if a Public IP is required"
  type        = string
}

variable "data_disk_sizes" {
  description = "List of disk sizes in GB"
  type        = list(string)

  validation {
    condition     = length(var.data_disk_sizes) == length(var.data_disk_types)
    error_message = "Number of disk sizes must match number of disk types."
  }
}

variable "data_disk_types" {
  description = "List of Azure disk types"
  type        = list(string)
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
}

