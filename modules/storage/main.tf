resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_kind             = "StorageV2" # StorageV2 / BlockBlobStorage / FileStorage / BlobStorage
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = "Hot"    # Hot / Cool / Cold
  min_tls_version          = "TLS1_2" # TLS1_0 / TLS1_1 / TLS1_2
  tags                     = var.tags

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${var.storage_account_name}-pe"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = var.private_endpoint_subresource_name
  }
}
