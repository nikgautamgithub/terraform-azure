data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "logic_app_subnet" {
  name                 = var.logic_app_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "pe-subnet-id" {
  count                = var.private_endpoint_name != null ? 1 : 0
  name                 = var.inbound_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
