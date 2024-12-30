# modules/azure_acr/outputs.tf
output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "The admin username of the Azure Container Registry"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
}

output "admin_password" {
  description = "The admin password of the Azure Container Registry"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}
