

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
  vm_resources         = [for resource in local.resources : resource if resource.type == "vm"]
  acr_resources        = [for resource in local.resources : resource if resource.type == "acr"]
  mi_resources         = [for resource in local.resources : resource if resource.type == "mi"]
  kv_resource          = [for resource in local.resources : resource if resource.type == "kv"]
  databricks_resources = [for resource in local.resources : resource if resource.type == "databricks"]
  aks_resource         = [for resource in local.resources : resource if resource.type == "aks"]
  servicebus_resource  = [for resource in local.resources : resource if resource.type == "servicebus"]
  df_resources         = [for resource in local.resources : resource if resource.type == "df"]
  storage_resources    = [for resource in local.resources : resource if resource.type == "storage"]
  apim_resources       = [for resource in local.resources : resource if resource.type == "apim"]
  sendgrid_resources   = [for resource in local.resources : resource if resource.type == "sendgrid"]
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
  for_each = { for idx, resource in local.mi_resources : idx => resource }

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

module "databricks" {
  for_each = { for idx, resource in local.databricks_resources : idx => resource }

  source = "./modules/azure_databricks_workspace"

  workspace_name             = each.value.workspace_name
  resource_group_name        = each.value.resource_group_name
  region                     = each.value.region
  sku                        = each.value.sku
  vnet_id                    = each.value.vnet_id
  private_subnet_name        = each.value.private_subnet_name
  private_subnet_nsg_id      = each.value.private_subnet_nsg_id
  public_subnet_name         = each.value.public_subnet_name
  public_subnet_nsg_id       = each.value.public_subnet_nsg_id
  private_endpoint_subnet_id = each.value.sku == "premium" ? each.value.private_endpoint_subnet_id : null
  tags                       = try(each.value.tags, {})
}
# module "aks" {
#   for_each = { for idx, resource in local.aks_resource : idx => resource }

#   source = "./modules/azure_aks"

#   cluster_name               = each.value.cluster_name
#   region                     = each.value.region
#   resource_group_name        = each.value.resource_group_name
#   dns_prefix                 = each.value.dns_prefix
#   kubernetes_version         = each.value.kubernetes_version

#   tags                       = try(each.value.tags, {})
# }

module "servicebus" {
  for_each = { for idx, resource in local.servicebus_resource : idx => resource }

  source = "./modules/azure_servicebus"

  namespace_name      = each.value.namespace_name
  region              = each.value.region
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  minimum_tls_version = each.value.minimum_tls_version
  tags                = try(each.value.tags, {})
}

module "azure_data_factory" {
  for_each = { for idx, resource in local.df_resources : idx => resource }

  source = "./modules/azure_df"

  data_factory_name   = each.value.data_factory_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  subnet_id           = try(each.value.subnet_id, null)
  subresource         = try(each.value.subresource, ["dataFactory"])
  tags                = try(each.value.tags, {})
}

module "storage" {
  for_each = { for idx, resource in local.storage_resources : idx => resource }

  source = "./modules/azure_storage"

  resource_group_name      = each.value.resource_group_name
  region                   = each.value.region
  storage_account_name     = each.value.storage_account_name
  subnet_id                = each.value.subnet_id
  subresource              = each.value.subresource
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  tags                     = try(each.value.tags, {})
}

module "azure_apim" {
  for_each = { for idx, resource in local.apim_resources : idx => resource }

  source = "./modules/azure_apim"

  apim_name                     = each.value.apim_name
  resource_group_name           = each.value.resource_group_name
  region                        = each.value.region
  publisher_name                = each.value.publisher_name
  publisher_email               = each.value.publisher_email
  sku_name                      = try(each.value.sku_name, "Developer_1")
  connectivity_type             = try(each.value.connectivity_type, "None")
  subnet_id                     = try(each.value.subnet_id, null)
  subresource                   = try(each.value.subresource, ["gateway"])
  existing_application_insights = each.value.existing_application_insights
  tags                          = try(each.value.tags, {})
}

module "azure_sendgrid" {
  for_each = { for idx, resource in local.sendgrid_resources : idx => resource }

  source = "./modules/azure_sendgrid"

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  plan                = each.value.plan
  tags                = try(each.value.tags, {})
}




