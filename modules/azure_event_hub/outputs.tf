output "namespace_id" {
  description = "ID of the created Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.id
}

output "namespace_name" {
  description = "Name of the created Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.name
}
