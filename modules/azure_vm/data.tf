data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_network_security_group" "existing_nsg" {
  name                = var.nsg_name
  resource_group_name = var.resource_group_name
}

# data "azurerm_shared_image_version" "windows_image" {
#   count               = var.os_type == "Windows" ? 1 : 0
#   name                = "latest"
#   image_name          = "myImageDefinition"
#   gallery_name        = "mygallery"
#   resource_group_name = var.resource_group_name
# }
