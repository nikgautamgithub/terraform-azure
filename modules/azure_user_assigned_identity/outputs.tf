output "identity_id" {
  description = "The ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.identity.id
}
