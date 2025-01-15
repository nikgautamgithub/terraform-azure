data "azurerm_application_insights" "existing" {
  count               = var.existing_application_insights != null ? 1 : 0
  name                = var.existing_application_insights
  resource_group_name = var.resource_group_name
}
