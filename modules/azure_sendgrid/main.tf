resource "azurerm_sendgrid_account" "sendgrid" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.region
  plan_name           = var.plan
  recurring_billing   = var.recurring_billing
  billing_cycle_term  = "1-month" # Hardcoded as per requirements
  tags                = var.tags
}
