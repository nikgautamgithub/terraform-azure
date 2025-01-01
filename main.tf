

provider "azurerm" {
  tenant_id       = local.tenant_id
  client_id       = local.client_id
  client_secret   = local.client_secret
  subscription_id = var.subscription_id

  features {}
}

locals {
  tenant_id     = "f7b668af-2f70-4101-a8de-8315bb4d00e7"
  client_id     = "f4ae8dcd-ff11-4539-8c84-cdb836175109"
  client_secret = "Jdv8Q~d-IEhZF0tFyzJxibvz.CdDa8ec3dt34bxH"
  resources     = var.resource_definitions
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
  location            = each.value.location
  vm_size             = each.value.vm_size
  os_type             = each.value.os_type
  os_disk_image       = each.value.os_disk_image
  os_disk_size        = each.value.os_disk_size
  os_disk_type        = each.value.os_disk_type
  zones               = length(each.value.zones) > 0 ? each.value.zones : ["1"]
  nsg_name            = each.value.nsg_name
  vnet_name           = each.value.vnet_name
  subnet_name         = each.value.subnet_name
  nic_name            = each.value.nic_name
  allowed_ports       = try(each.value.allowed_ports, [])
  public_ip_required  = each.value.public_ip_required
  data_disks          = try(each.value.data_disks, [])
  disk_types          = try(each.value.disk_types, [])
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
}

module "azure_acr" {
  for_each = { for idx, resource in local.acr_resources : idx => resource }

  source = "./modules/azure_acr"

  acr_name            = each.value.acr_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = try(each.value.sku, "Basic")
  tags                = try(each.value.tags, {})

}

module "azure_user_assigned_identity" {
  for_each = { for idx, resource in local.identity_resources : idx => resource }

  source = "./modules/azure_user_assigned_identity"

  identity_name       = each.value.identity_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = try(each.value.tags, {})
}

module "azure_key_vault" {
  for_each = { for idx, resource in local.kv_resource : idx => resource }

  source = "./modules/azure_key_vault"

  key_vault_name      = each.value.key_vault_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tenant_id           = local.tenant_id
  sku_name            = try(each.value.sku_name, "Basic")
  tags                = try(each.value.tags, {})
}
