resource "azurerm_service_plan" "plan" {
  name                = "${var.name}-plan"
  location            = var.region
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = var.pricing_plan
}

resource "azurerm_logic_app_standard" "logic_app" {
  depends_on          = [azurerm_service_plan.plan]
  name                = var.name
  location            = var.region
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.plan.id

  storage_account_name       = data.azurerm_storage_account.storage.name
  storage_account_access_key = data.azurerm_storage_account.storage.primary_access_key

  virtual_network_subnet_id = data.azurerm_subnet.logic_app_subnet.id
  public_network_access     = "Disabled"
  https_only                = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                 = "dotnet-isolated"
    "WEBSITE_NODE_DEFAULT_VERSION"             = "~18"
  }

  site_config {
    dotnet_framework_version  = "v6.0"
    use_32_bit_worker_process = false
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "logic_app_pe" {
  count               = var.private_endpoint_name != null ? 1 : 0
  name                = var.private_endpoint_name
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.pe-subnet-id[0].id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-connection"
    private_connection_resource_id = azurerm_logic_app_standard.logic_app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  tags = var.tags
}

# Optional Application Insights
resource "azurerm_application_insights" "insights" {
  count               = var.enable_application_insights ? 1 : 0
  name                = "${var.name}-appinsights"
  location            = var.region
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags                = var.tags
}
