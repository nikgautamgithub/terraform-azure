resource "azurerm_servicebus_namespace" "servicebus" {
  name                = var.namespace_name
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  minimum_tls_version = var.minimum_tls_version
  tags                = var.tags
}
