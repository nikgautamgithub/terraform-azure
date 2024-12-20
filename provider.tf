# Example of using multiple provider aliases for multiple subscriptions
provider "azurerm" {
  features {}
  # authentication done via environment variables or managed identities
}

# Example alias
provider "azurerm" {
  alias           = "sub_1"
  features        {}
  subscription_id = var.subscription_1_id
}

provider "azurerm" {
  alias           = "sub_2"
  features        {}
  subscription_id = var.subscription_2_id
}
