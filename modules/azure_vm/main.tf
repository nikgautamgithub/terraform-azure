terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size

  admin_username = "adminuser"
  admin_password = "replace-with-your-password" # Consider using a more secure method like Key Vault or SSH keys

  network_interface_ids = [azurerm_network_interface.example.id] # Ensure this is defined or passed as a variable

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size

  admin_username = "adminuser"
  admin_password = "replace-with-your-password" # Consider using a more secure method like Key Vault

  network_interface_ids = [azurerm_network_interface.example.id] # Ensure this is defined or passed as a variable

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
