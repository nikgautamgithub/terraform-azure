# Load variables from terraform.tfvars or environment variables
# Providers for multi-subscription handling would be defined in provider.tf

# Loop through the resource_definitions and call modules dynamically
locals {
  vms = [for r in var.resource_definitions : r if r.type == "vm"]
  aks = [for r in var.resource_definitions : r if r.type == "aks"]
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

module "azure_aks" {
  for_each = { for idx, vm in local.aks : idx => aks }

  source         = "./modules/azure_aks"
  subscription_id = each.value.subscription_id
}
