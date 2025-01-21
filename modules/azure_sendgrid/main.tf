resource "azurerm_marketplace_agreement" "sendgrid" {
  publisher = "sendgrid"
  offer     = "tsg-saas-offer"
  plan      = "free-100-2022"
}

resource "azurerm_resource_group_template_deployment" "sendgrid" {
  name                = var.name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_content = jsonencode({
    "$schema" : "http://schema.management.azure.com/schemas/2015-01-01-preview/deploymentTemplate.json#",
    "contentVersion" : "1.0.0.0",
    "parameters" : {
      "name" : {
        "type" : "String"
      },
      "planId" : {
        "type" : "String"
      },
      "offerId" : {
        "type" : "String"
      },
      "publisherId" : {
        "type" : "String"
      },
      "quantity" : {
        "type" : "Int"
      },
      "termId" : {
        "type" : "String"
      },
      "azureSubscriptionId" : {
        "type" : "String"
      },
      "publisherTestEnvironment" : {
        "type" : "String"
      },
      "autoRenew" : {
        "type" : "Bool"
      },
      "location" : {
        "type" : "String"
      },
      "tags" : {
        "type" : "Object"
      },
      "riskPropertyBagHeader" : {
        "type" : "String"
      }
    },
    "resources" : [
      {
        "type" : "Microsoft.SaaS/resources",
        "apiVersion" : "2018-03-01-beta",
        "name" : "[parameters('name')]",
        "location" : "[parameters('location')]",
        "tags" : "[parameters('tags')]",
        "properties" : {
          "saasResourceName" : "[parameters('name')]",
          "publisherId" : "[parameters('publisherId')]",
          "SKUId" : "[parameters('planId')]",
          "offerId" : "[parameters('offerId')]",
          "quantity" : "[parameters('quantity')]",
          "termId" : "[parameters('termId')]",
          "autoRenew" : "[parameters('autoRenew')]",
          "paymentChannelType" : "SubscriptionDelegated",
          "paymentChannelMetadata" : {
            "AzureSubscriptionId" : "[parameters('azureSubscriptionId')]"
          },
          "publisherTestEnvironment" : "[parameters('publisherTestEnvironment')]",
          "storeFront" : "AzurePortal",
          "riskPropertyBagHeader" : "[parameters('riskPropertyBagHeader')]"
        }
      }
    ]
  })

  parameters_content = jsonencode({
    "name" : {
      "value" : var.name
    },
    "planId" : {
      "value" : "free-100-2022"
    },
    "offerId" : {
      "value" : "tsg-saas-offer"
    },
    "publisherId" : {
      "value" : "sendgrid"
    },
    "quantity" : {
      "value" : 1
    },
    "termId" : {
      "value" : "hjdtn7tfnxcy"
    },
    "azureSubscriptionId" : {
      "value" : var.subscription_id
    },
    "publisherTestEnvironment" : {
      "value" : "False"
    },
    "autoRenew" : {
      "value" : true
    },
    "location" : {
      "value" : "global"
    },
    "tags" : {
      "value" : var.tags
    },
    "riskPropertyBagHeader" : {
      "value" : ""
    }
  })

  depends_on = [
    azurerm_marketplace_agreement.sendgrid
  ]
}
