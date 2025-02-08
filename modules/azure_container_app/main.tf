resource "azurerm_log_analytics_workspace" "env_analytics" {
  count               = var.logs_destination == "log-analytics" ? 1 : 0
  name                = "logs-${var.container_app_env_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app_environment" "env" {
  name                       = var.container_app_env_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  zone_redundancy_enabled    = var.zone_redundancy_enabled
  logs_destination           = var.logs_destination
  log_analytics_workspace_id = var.logs_destination == "log-analytics" ? azurerm_log_analytics_workspace.env_analytics[0].id : null

  workload_profile {
    name                  = "wp-${var.container_app_env_name}"
    workload_profile_type = var.workload_profile
    maximum_count         = var.workload_profile_max_count
    minimum_count         = var.workload_profile_min_count
  }

  infrastructure_subnet_id = var.subnet_id
}

resource "azurerm_container_app" "app" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.container_name
      image  = "${var.registry_server}/${var.image}:${var.image_tag}"
      cpu    = var.cpu
      memory = var.memory
    }
  }

  registry {
    server   = var.registry_server
    identity = "SystemAssigned"
  }

  tags = var.tags
}
