

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

  workspace_name      = each.value.workspace_name
  resource_group_name = each.value.resource_group_name
  region              = each.value.region
  sku                 = each.value.sku

  vnet_id               = each.value.vnet_id
  private_subnet_name   = each.value.private_subnet_name
  private_subnet_nsg_id = each.value.private_subnet_nsg_id
  public_subnet_name    = each.value.public_subnet_name
  public_subnet_nsg_id  = each.value.public_subnet_nsg_id

  private_endpoint_subnet_id = each.value.sku == "premium" ? each.value.private_endpoint_subnet_id : null

  tags = try(each.value.tags, {})
}
module "aks" {
  for_each = { for idx, resource in local.aks_resource : idx => resource }

  source = "./modules/azure_aks"

  cluster_name               = each.value.cluster_name
  region                     = each.value.region
  resource_group_name        = each.value.resource_group_name
  dns_prefix                 = each.value.dns_prefix
  kubernetes_version         = each.value.kubernetes_version
  system_node_count          = each.value.system_node_count
  user_node_count            = each.value.user_node_count
  enable_auto_scaling        = each.value.enable_auto_scaling
  system_node_min_count      = each.value.system_node_min_count
  system_node_max_count      = each.value.system_node_max_count
  network_plugin             = each.value.network_plugin
  network_policy             = each.value.network_policy
  load_balancer_sku          = each.value.load_balancer_sku
  aad_rbac_enabled           = each.value.aad_rbac_enabled
  aad_admin_group_object_ids = each.value.aad_admin_group_object_ids
  tags                       = try(each.value.tags, {})
}

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
