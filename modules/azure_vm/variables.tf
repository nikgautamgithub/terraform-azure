variable "provider_alias" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}
