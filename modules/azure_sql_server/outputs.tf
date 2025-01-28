output "server_id" {
  description = "The ID of the SQL Server"
  value       = azurerm_mssql_server.server.id
}

output "server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.server.name
}
