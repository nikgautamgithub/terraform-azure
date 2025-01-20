output "id" {
  description = "The ID of the deployed SendGrid resource"
  value       = jsondecode(azurerm_resource_group_template_deployment.sendgrid.output_content).id
}

output "name" {
  description = "The name of the deployed SendGrid resource"
  value       = var.name
}
