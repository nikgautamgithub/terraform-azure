locals {
  is_premium = can(regex("^Premium_", var.sku_name))
  zones_list = local.is_premium ? var.zones : []
}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.region
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name
  zones               = local.zones_list

  identity {
    type = "SystemAssigned"
  }

  dynamic "virtual_network_configuration" {
    for_each = var.connectivity_type == "Virtual Network" ? [1] : []
    content {
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_api_management_logger" "logger" {
  count               = var.existing_application_insights != null ? 1 : 0
  name                = "appinsights-logger"
  api_management_name = var.apim_name
  resource_group_name = var.resource_group_name

  application_insights {
    instrumentation_key = data.azurerm_application_insights.existing[0].instrumentation_key
  }

  depends_on = [
    data.azurerm_application_insights.existing, azurerm_api_management.apim
  ]
}

resource "azurerm_private_endpoint" "apim_pe" {
  count               = var.connectivity_type == "Private Endpoint" ? 1 : 0
  name                = "${var.apim_name}-pe"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.apim_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_api_management.apim.id
    is_manual_connection           = false
    subresource_names              = [var.subresource]
  }

  depends_on = [
    azurerm_api_management.apim
  ]
}
