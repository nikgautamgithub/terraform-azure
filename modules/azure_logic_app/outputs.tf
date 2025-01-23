output "logic_app_id" {
  description = "ID of the Logic App"
  value       = azurerm_logic_app_standard.logic_app.id
}

output "logic_app_name" {
  description = "Name of the Logic App"
  value       = azurerm_logic_app_standard.logic_app.name
}

output "logic_app_url" {
  description = "URL of the Logic App"
  value       = azurerm_logic_app_standard.logic_app.default_hostname
}