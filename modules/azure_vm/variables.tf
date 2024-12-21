variable "subscription_id" { type = string }
variable "vm_name" { type = string }
variable "resource_group_name" { type = string }
variable "os_type" { type = string }
variable "os_disk_image" { type = string }
variable "os_disk_type" { type = string }
variable "vm_size" { type = string }
variable "location" { type = string }
variable "zones" { type = string }
variable "nsg_names" { type = string }
variable "vnet_names" { type = string }
variable "nic_names" { type = string }
variable "subnet_names" { type = string }
variable "allowed_ports" { type = list(string) }
variable "public_ip_required" { type = string }
variable "data_disk_sizes" { type = list(string) }
variable "data_disk_types" { type = list(string) }
variable "admin_username" { type = string }
variable "admin_password" { type = string }
