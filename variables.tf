variable "resource_definitions" {
  type = list(object({
    subscription_id     = string
    vm_name             = string
    resource_group_name = string
    location            = string
    vm_size             = string
    os_type             = string
    os_disk_image       = string
    os_disk_type        = string
    zones               = optional(list(string))
    nsg_names           = string
    vnet_names          = string
    subnet_names        = string
    nic_names           = string
    allowed_ports       = optional(list(string))
    public_ip_required  = bool
    data_disks          = optional(list(number))
    disk_types          = optional(list(string))
    admin_username      = string
    admin_password      = string
  }))
}
