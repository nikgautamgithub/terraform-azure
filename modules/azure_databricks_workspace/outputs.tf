output "workspace_id" {
  description = "The ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.workspace.id
}

output "workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.workspace.workspace_url
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = azurerm_private_endpoint.databricks_pe[*].private_service_connection[0].private_ip_address
}
