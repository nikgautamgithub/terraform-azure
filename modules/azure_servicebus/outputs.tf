output "servicebus_namespace_id" {
  description = "The ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.servicebus.id
}

output "servicebus_namespace_name" {
  description = "The name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.servicebus.name
}
