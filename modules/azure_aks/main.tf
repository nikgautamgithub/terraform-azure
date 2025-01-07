# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.system_node_pool_name
    node_count      = var.system_node_count
    vm_size         = var.system_node_vm_size
    type            = var.system_node_pool_type
    min_count       = var.enable_auto_scaling ? var.system_node_min_count : null
    max_count       = var.enable_auto_scaling ? var.system_node_max_count : null
    os_disk_size_gb = var.system_node_disk_size
    os_sku          = var.os_sku
    zones           = var.availability_zones
    vnet_subnet_id  = var.vnet_subnet_id
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
  }

  identity {
    type = var.identity_type
  }

  role_based_access_control_enabled = var.rbac_enabled

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aad_rbac_enabled ? [1] : []
    content {
      admin_group_object_ids = var.aad_admin_group_object_ids
      azure_rbac_enabled     = true
    }
  }

  tags = var.tags
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  count = var.enable_user_node_pool ? 1 : 0

  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  node_count            = var.user_node_count
  mode                  = "User"
  os_disk_size_gb       = var.user_node_disk_size
  os_sku                = var.os_sku
  zones                 = var.availability_zones
  vnet_subnet_id        = var.vnet_subnet_id

  min_count = var.enable_user_auto_scaling ? var.user_node_min_count : null
  max_count = var.enable_user_auto_scaling ? var.user_node_max_count : null

  tags = var.tags
}
