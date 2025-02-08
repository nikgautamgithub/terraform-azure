output "synapse_workspace_id" {
  value       = azurerm_synapse_workspace.synapse.id
  description = "The ID of the Azure Synapse Workspace"
}

output "synapse_workspace_name" {
  value       = azurerm_synapse_workspace.synapse.name
  description = "The name of the Azure Synapse Workspace"
}
