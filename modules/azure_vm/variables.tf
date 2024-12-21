variable "subscription_id" {
  type = string
}

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

variable "zones" {
  type    = list(string)
  default = []
}

variable "nsg_names" {
  type = string
}

variable "vnet_names" {
  type = string
}

variable "subnet_names" {
  type = string
}

variable "nic_names" {
  type = string
}

variable "allowed_ports" {
  type = list(string)
}

variable "public_ip_required" {
  type = bool
}

variable "data_disks" {
  type    = list(number)
  default = []
}

variable "disk_types" {
  type    = list(string)
  default = []
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}
