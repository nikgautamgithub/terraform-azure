terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Load resource definitions
locals {
  resources = var.resource_definitions
}

# Group VM resources
locals {
  vm_resources = [for resource in local.resources : resource if resource.type == "vm"]
}

# Call VM module dynamically
module "azure_vm" {
  for_each = { for idx, resource in local.vm_resources : idx => resource }

  source = "./modules/azure_vm"

  # Pass subscription_id dynamically as a variable
  providers = {
    azurerm = azurerm
  }

  subscription_id     = each.value.subscription_id
  vm_name             = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  vm_size             = each.value.vm_size
  os_type             = each.value.os_type
  os_disk_image       = each.value.os_disk_image
  os_disk_type        = each.value.os_disk_type
  zones               = try([each.value.zones], null)
  nsg_names           = each.value.nsg_names
  vnet_names          = each.value.vnet_names
  subnet_names        = each.value.subnet_names
  nic_names           = each.value.nic_names
  allowed_ports       = each.value.allowed_ports
  public_ip_required  = each.value.public_ip_required
  data_disks          = each.value.data_disks
  disk_types          = each.value.disk_types
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
}
