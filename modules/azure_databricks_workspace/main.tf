# Network Security Group for Private Subnet
resource "azurerm_network_security_group" "private_nsg" {
  name                = "databricks-private-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowPrivateCIDR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.private_allowed_cidr
    destination_address_prefix = "*"
  }
}

# Network Security Group for Public Subnet
resource "azurerm_network_security_group" "public_nsg" {
  name                = "databricks-public-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowPublicCIDR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.public_allowed_cidr
    destination_address_prefix = "*"
  }
}

# Private Subnet
resource "azurerm_subnet" "private_subnet" {
  name                 = var.private_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = [var.private_subnet_cidr]

  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

# Public Subnet
resource "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.databricks_vnet.name
  address_prefixes     = [var.public_subnet_cidr]

  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

# Databricks Workspace
resource "azurerm_databricks_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.region
  sku                 = var.sku

  tags = var.tags

  public_network_access_enabled         = false
  network_security_group_rules_required = var.network_security_group_rules

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = azurerm_subnet.private_subnet.name
    public_subnet_name                                   = azurerm_subnet.public_subnet.name
    private_subnet_network_security_group_association_id = azurerm_network_security_group.private_nsg.id
    public_subnet_network_security_group_association_id  = azurerm_network_security_group.public_nsg.id
  }
}

resource "azurerm_private_endpoint" "databricks_pe" {
  name                = "pe-${var.workspace_name}"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.workspace_name}"
    private_connection_resource_id = azurerm_databricks_workspace.workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }
}
