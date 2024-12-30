variable "vm_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "os_type" {
  type = string
}

variable "os_disk_image" {
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

variable "nic_name" {
  description = "Names of the Network Interfaces for the VM"
  type        = string
}

variable "allowed_ports" {
  description = "List of allowed ports for NSG rules"
  type        = list(string)
  default     = []
}

variable "public_ip_required" {
  description = "Flag to indicate if a Public IP is required"
  type        = string
}

variable "data_disks" {
  type    = set(string)
  default = []
}

variable "disk_types" {
  type    = list(string)
  default = []
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
}

variable "availability_set_id" {
  description = "ID of the availability set (if any)"
  type        = string
  default     = null
}
