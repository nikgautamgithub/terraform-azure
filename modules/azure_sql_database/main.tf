locals {
  private_endpoint_name = "${var.database_name}-pe"
}

resource "azurerm_mssql_database" "sql_db" {
  name                 = var.database_name
  server_id            = var.server_id
  elastic_pool_id      = null
  sku_name             = var.compute_storage
  storage_account_type = var.redundancy
  tags                 = var.tags
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = local.private_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.private_endpoint_name}-connection"
    private_connection_resource_id = var.server_id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  depends_on = [azurerm_mssql_database.sql_db]
}
