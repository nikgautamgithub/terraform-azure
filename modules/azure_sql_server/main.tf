resource "azurerm_mssql_server" "server" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.admin_username.value
  administrator_login_password = data.azurerm_key_vault_secret.admin_password.value

  # Hardcoded security settings as per requirements
  public_network_access_enabled        = true
  minimum_tls_version                  = "1.2"
  outbound_network_restriction_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
