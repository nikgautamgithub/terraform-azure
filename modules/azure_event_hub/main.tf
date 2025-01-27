resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.pricing_tier
  capacity            = var.throughput_units

  minimum_tls_version = "1.2"

  local_authentication_enabled  = true
  public_network_access_enabled = true

  network_rulesets {
    default_action = var.pricing_tier != "Basic" ? "Deny" : "Allow"
  }

  tags = var.tags
}

# If private endpoint is enabled and pricing tier is not Basic
resource "azurerm_private_endpoint" "eventhub_pe" {
  count               = var.private_endpoint_subnet_id && var.pricing_tier != "Basic" ? 1 : 0
  name                = "${var.namespace_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.namespace_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_eventhub_namespace.eventhub_namespace.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
}
