output "database_id" {
  description = "The ID of the SQL Database"
  value       = azurerm_mssql_database.sql_db.id
}

output "private_endpoint_id" {
  description = "The ID of the Private Endpoint"
  value       = azurerm_private_endpoint.sql_pe.id
}
