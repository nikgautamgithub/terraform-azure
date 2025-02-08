resource "azurerm_synapse_workspace" "synapse" {
  name                                 = var.workspace_name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = "https://${var.account_name}.dfs.core.windows.net/${var.filesystem_name}"

  azuread_authentication_only = true

  managed_virtual_network_enabled = true
  public_network_access_enabled   = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
