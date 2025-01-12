resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled = true

  lifecycle {
    ignore_changes = [
      vsts_configuration,
      github_configuration
    ]
  }
}

resource "azurerm_private_endpoint" "adf_pe" {
  name                = "${var.data_factory_name}-pe"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.data_factory_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_data_factory.adf.id
    is_manual_connection           = false
    subresource_names              = [var.subresource]
  }
}
