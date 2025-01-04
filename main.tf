

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret

  features {}
}

locals {
  resources = var.resource_definitions
}

# Group VM resources
locals {
  vm_resources       = [for resource in local.resources : resource if resource.type == "vm"]
  acr_resources      = [for resource in local.resources : resource if resource.type == "acr"]
  identity_resources = [for resource in local.resources : resource if resource.type == "identity"]
  kv_resource        = [for resource in local.resources : resource if resource.type == "kv"]
}

# Call the VM module
module "azure_vm" {
  for_each = { for idx, resource in local.vm_resources : idx => resource }

  source = "./modules/azure_vm"

  vm_name             = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  vm_size             = each.value.vm_size
  os_type             = each.value.os_type
  os_image            = each.value.os_image
  os_disk_size        = each.value.os_disk_size
  os_disk_type        = each.value.os_disk_type
  zones               = try(each.value.zones, [])
  nsg_name            = each.value.nsg_name
  vnet_name           = each.value.vnet_name
  subnet_name         = each.value.subnet_name
  ports               = try(each.value.ports, [])
  public_ip_required  = each.value.public_ip_required
  data_disk_sizes     = try(each.value.data_disk_sizes, [])
  data_disk_types     = try(each.value.data_disk_types, [])
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
}

module "azure_acr" {
  for_each = { for idx, resource in local.acr_resources : idx => resource }

  source = "./modules/azure_acr"

  acr_name            = each.value.acr_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  sku                 = try(each.value.sku, "Basic")
  tags                = try(each.value.tags, {})

}

module "azure_user_assigned_identity" {
  for_each = { for idx, resource in local.identity_resources : idx => resource }

  source = "./modules/azure_user_assigned_identity"

  identity_name       = each.value.identity_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  tags                = try(each.value.tags, {})
}

module "azure_key_vault" {
  for_each = { for idx, resource in local.kv_resource : idx => resource }

  source = "./modules/azure_key_vault"

  key_vault_name      = each.value.key_vault_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  tenant_id           = var.tenant_id
  sku_name            = try(each.value.sku_name, "Basic")
  tags                = try(each.value.tags, {})
}
