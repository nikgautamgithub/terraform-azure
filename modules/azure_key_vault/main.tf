resource "azurerm_key_vault" "key_vault" {
  name                          = var.key_vault_name
  resource_group_name           = var.resource_group_name
  location                      = var.region
  sku_name                      = var.sku_name
  tenant_id                     = var.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false

  tags = var.tags
}
