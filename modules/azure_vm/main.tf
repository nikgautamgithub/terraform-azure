provider "azurerm" {
  alias           = "module_provider"
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [var.nic_names]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = split(":", var.os_disk_image)[0]
    offer     = split(":", var.os_disk_image)[1]
    sku       = split(":", var.os_disk_image)[2]
    version   = "latest"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [var.nic_names]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = split("/", var.os_disk_image)[0]
    offer     = split("/", var.os_disk_image)[1]
    sku       = split("/", var.os_disk_image)[2]
    version   = "latest"
  }

  lifecycle {
    prevent_destroy = true
  }
}
