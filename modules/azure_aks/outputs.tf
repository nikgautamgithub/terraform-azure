output "cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "The ID of the AKS cluster"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the AKS cluster"
}

output "cluster_resource_group" {
  value       = azurerm_kubernetes_cluster.aks.resource_group_name
  description = "The resource group where the AKS cluster is deployed"
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
  description = "Raw kubeconfig content"
}

output "kube_config" {
  value = {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_key             = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
    client_certificate     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
    cluster_ca_certificate = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  }
  sensitive   = true
  description = "Structured kubeconfig data"
}

output "cluster_endpoint" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  description = "The endpoint for the AKS cluster API server"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
  description = "The resource group containing the AKS cluster nodes"
}

output "system_node_pool_id" {
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].id
  description = "The ID of the default system node pool"
}

output "user_node_pool_id" {
  value       = var.enable_user_node_pool ? azurerm_kubernetes_cluster_node_pool.user_pool[0].id : null
  description = "The ID of the user node pool"
}
