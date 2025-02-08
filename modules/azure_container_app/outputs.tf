output "container_app_id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.app.id
}

output "container_app_url" {
  description = "URL of the Container App"
  value       = azurerm_container_app.app.latest_revision_fqdn
}

output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.env.id
}