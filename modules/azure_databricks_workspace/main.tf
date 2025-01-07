resource "azurerm_databricks_workspace" "workspace" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.region
  sku                 = var.sku

  tags = var.tags

  public_network_access_enabled         = var.sku == "premium" ? false : null
  network_security_group_rules_required = var.sku == "premium" ? var.network_security_group_rules : null

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_id
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_id
  }
}

resource "azurerm_private_endpoint" "databricks_pe" {
  count               = var.sku == "premium" ? 1 : 0
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
