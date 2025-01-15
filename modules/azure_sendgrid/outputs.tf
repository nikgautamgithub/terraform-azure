output "sendgrid_id" {
  description = "The ID of the created SendGrid account"
  value       = azurerm_sendgrid_account.sendgrid.id
}
