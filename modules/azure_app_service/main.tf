resource "azurerm_service_plan" "plan" {
  name                = "${var.name}-plan"
  location            = var.region
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.pricing_plan
}

locals {
  default_app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = "true"
  }
}

locals {
  valid_dotnet_versions = ["3.1", "5.0", "6.0", "7.0", "8.0", "9.0"]
  valid_go_versions     = ["1.18", "1.19"]
  valid_java_versions   = ["8", "11", "17", "21"]
  valid_node_versions   = ["18-lts", "20-lts"]
  valid_php_versions    = ["7.4", "8.0", "8.1", "8.2", "8.3"]
  valid_python_versions = ["3.8", "3.9", "3.10", "3.11", "3.12"]
  valid_ruby_versions   = ["2.6", "2.7"]

  # Validation checks
  is_valid_dotnet_version = var.runtime_stack == "dotnet" ? contains(local.valid_dotnet_versions, var.runtime_version) : true
  is_valid_go_version     = var.runtime_stack == "go" ? contains(local.valid_go_versions, var.runtime_version) : true
  is_valid_java_version   = var.runtime_stack == "java" ? contains(local.valid_java_versions, var.runtime_version) : true
  is_valid_node_version   = var.runtime_stack == "node" ? contains(local.valid_node_versions, var.runtime_version) : true
  is_valid_php_version    = var.runtime_stack == "php" ? contains(local.valid_php_versions, var.runtime_version) : true
  is_valid_python_version = var.runtime_stack == "python" ? contains(local.valid_python_versions, var.runtime_version) : true
  is_valid_ruby_version   = var.runtime_stack == "ruby" ? contains(local.valid_ruby_versions, var.runtime_version) : true

  # Validate Java configuration
  java_config_valid = var.runtime_stack == "java" ? (
    var.java_server != null &&
    var.java_server_version != null &&
    var.runtime_version != null
  ) : true

  # Validate Docker configuration
  docker_config_valid = var.runtime_stack == "docker" ? (
    var.docker_image != null &&
    var.docker_registry_url != null
  ) : true
}

resource "azurerm_linux_web_app" "app_linux" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.region
  service_plan_id     = azurerm_service_plan.plan.id

  public_network_access_enabled = false

  site_config {

    application_stack {
      # Docker configuration
      docker_image_name        = var.runtime_stack == "docker" ? var.docker_image : null
      docker_registry_url      = var.runtime_stack == "docker" ? var.docker_registry_url : null
      docker_registry_username = var.runtime_stack == "docker" ? var.docker_registry_username : null
      docker_registry_password = var.runtime_stack == "docker" ? var.docker_registry_password : null

      # Runtime stack configurations
      dotnet_version      = var.runtime_stack == "dotnet" ? var.runtime_version : null
      go_version          = var.runtime_stack == "go" ? var.runtime_version : null
      java_server         = var.runtime_stack == "java" ? var.java_server : null
      java_server_version = var.runtime_stack == "java" ? var.java_server_version : null
      java_version        = var.runtime_stack == "java" ? var.runtime_version : null
      node_version        = var.runtime_stack == "node" ? var.runtime_version : null
      php_version         = var.runtime_stack == "php" ? var.runtime_version : null
      python_version      = var.runtime_stack == "python" ? var.runtime_version : null
      ruby_version        = var.runtime_stack == "ruby" ? var.runtime_version : null
    }
  }

  app_settings = local.default_app_settings

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  virtual_network_subnet_id = var.vnet_integration_subnet_id

  tags = var.tags
}

check "runtime_version_validation" {
  assert {
    condition = (
      local.is_valid_dotnet_version &&
      local.is_valid_go_version &&
      local.is_valid_java_version &&
      local.is_valid_node_version &&
      local.is_valid_php_version &&
      local.is_valid_python_version &&
      local.is_valid_ruby_version
    )
    error_message = "Invalid runtime version specified for the selected runtime stack."
  }
}

check "java_config_validation" {
  assert {
    condition     = local.java_config_valid
    error_message = "When using Java runtime, java_server, java_server_version, and runtime_version (java_version) must all be specified."
  }
}

check "docker_config_validation" {
  assert {
    condition     = local.docker_config_valid
    error_message = "When using Docker runtime, docker_image and docker_registry_url must be specified."
  }
}

resource "azurerm_windows_web_app" "app_windows" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.region
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true

    application_stack {
      # Docker configuration
      docker_image_name        = var.runtime_stack == "docker" ? var.docker_image : null
      docker_registry_url      = var.runtime_stack == "docker" ? var.docker_registry_url : null
      docker_registry_username = var.runtime_stack == "docker" ? var.docker_registry_username : null
      docker_registry_password = var.runtime_stack == "docker" ? var.docker_registry_password : null

      current_stack  = var.runtime_stack
      dotnet_version = var.runtime_stack == "dotnet" ? var.runtime_version : null
      node_version   = var.runtime_stack == "node" ? var.runtime_version : null
      php_version    = var.runtime_stack == "php" ? var.runtime_version : null
      java_version   = var.runtime_stack == "java" ? var.runtime_version : null
      python         = var.runtime_stack == "python" ? true : false
    }
  }

  app_settings = local.default_app_settings

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  virtual_network_subnet_id = var.vnet_integration_subnet_id

  tags = var.tags
}

resource "azurerm_private_endpoint" "app_pe" {
  count               = var.private_endpoint_name != null ? 1 : 0
  name                = var.private_endpoint_name
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-connection"
    private_connection_resource_id = var.os_type == "Linux" ? azurerm_linux_web_app.app_linux[0].id : azurerm_windows_web_app.app_windows[0].id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    ]
  }
}
