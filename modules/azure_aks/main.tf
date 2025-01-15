resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  automatic_upgrade_channel = "patch"

  default_node_pool {
    name            = var.default_node_pool.name
    vm_size         = var.default_node_pool.vm_size
    node_count      = var.default_node_pool.node_count
    min_count       = var.default_node_pool.min_count
    max_count       = var.default_node_pool.max_count
    os_disk_size_gb = var.default_node_pool.os_disk_size_gb
    node_labels     = var.default_node_pool.node_labels
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = var.tenant_id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  for_each = var.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = each.key
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
}
