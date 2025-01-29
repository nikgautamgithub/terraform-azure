output "app_service_id" {
  description = "ID of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.app_linux[0].id : azurerm_windows_web_app.app_windows[0].id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = var.name
}

output "app_service_url" {
  description = "Default URL of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.app_linux[0].default_hostname : azurerm_windows_web_app.app_windows[0].default_hostname
}

output "app_service_identity" {
  description = "Identity block of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.app_linux[0].identity : azurerm_windows_web_app.app_windows[0].identity
}