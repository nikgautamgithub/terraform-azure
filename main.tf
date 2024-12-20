terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Load variables from terraform.tfvars or environment variables
# Providers for multi-subscription handling would be defined in provider.tf

# Loop through the resource_definitions and call modules dynamically
locals {
  vms = [for r in var.resource_definitions : r if r.type == "vm"]
}

# Create VMs
module "azure_vm" {
  for_each = { for idx, vm in local.vms : idx => vm }

  source         = "./modules/azure_vm"
  provider_alias = each.value.subscription_name
  name           = each.value.name
  resource_group = each.value.resource_group
  os_type        = each.value.os_type
  vm_size        = each.value.vm_size
  location       = var.location
}
