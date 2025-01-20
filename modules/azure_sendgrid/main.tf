resource "azurerm_marketplace_agreement" "sendgrid" {
  publisher = "sendgrid"
  offer     = "sendgrid_azure"
  plan      = var.plan
}

resource "azurerm_resource_group_template_deployment" "sendgrid" {
  name                = var.name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema" : "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion" : "1.0.0.0",
    "parameters" : {},
    "variables" : {},
    "resources" : [
      {
        "type" : "Microsoft.SaaS/resources",
        "apiVersion" : "2018-03-01-beta",
        "name" : var.name,
        "location" : var.region,
        "properties" : {
          "publisherId" : "sendgrid",
          "offerId" : "sendgrid_azure",
          "planId" : var.plan,
          "quantity" : 1,
          "termId" : "hjdtn7tfnxcy" # Monthly billing term
        },
        "tags" : var.tags
      }
    ]
  })

  depends_on = [
    azurerm_marketplace_agreement.sendgrid
  ]
}
