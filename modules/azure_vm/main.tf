locals {
  # Create a map of all disk configurations across all zones
  zonal_disks = merge([
    for zone_index in range(length(var.zones)) : {
      for disk_key, disk_size in var.data_disks :
      "${disk_key}-${zone_index}" => {
        size      = disk_size
        zone      = var.zones[zone_index]
        disk_type = var.disk_types[disk_key]
      }
    }
  ]...)
}

locals {
  os_image_id = "/subscriptions/6e47c803-d4a0-49b2-9b1f-01500ce57b80/resourceGroups/my-rg/providers/Microsoft.Compute/galleries/mygallery/images/myimagedef/versions/1.0.0"
}

resource "azurerm_public_ip" "vm_public_ip" {
  count               = var.public_ip_required == "yes" ? length(var.zones) : 0
  name                = length(var.zones) == 1 ? "${var.vm_name}-public-ip" : "${var.vm_name}-${count.index + 1}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [var.zones[count.index]]
}

resource "azurerm_network_interface" "vm_nic" {
  count               = length(var.zones)
  name                = length(var.zones) == 1 ? "${var.vm_name}-nic" : "${var.vm_name}-${count.index + 1}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.vm_name}-${count.index + 1}-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_required == "yes" ? azurerm_public_ip.vm_public_ip[count.index].id : null
  }
}

resource "azurerm_network_security_rule" "inbound_rules" {
  count                       = length(var.ports)
  name                        = "Allow-Port-${var.ports[count.index]}"
  priority                    = 1000 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.ports[count.index]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.nsg_name
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  count                     = length(var.zones)
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = data.azurerm_network_security_group.existing_nsg.id
}

resource "azurerm_managed_disk" "data_disks" {
  for_each             = local.zonal_disks
  name                 = "${var.vm_name}-zone${split("-", each.key)[1]}-disk-${split("-", each.key)[0]}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.disk_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size
  zone                 = each.value.zone
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = var.os_type == "Linux" ? length(var.zones) : 0
  name                = length(var.zones) == 1 ? "${var.vm_name}" : "${var.vm_name}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = var.zones[count.index]

  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.os_image
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count               = var.os_type == "Windows" ? length(var.zones) : 0
  name                = length(var.zones) == 1 ? "${var.vm_name}" : "${var.vm_name}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = var.zones[count.index]

  patch_mode               = "Manual"
  enable_automatic_updates = false
  license_type             = "Windows_Server"

  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }

  source_image_id = local.os_image_id

}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachments" {
  for_each           = local.zonal_disks
  managed_disk_id    = azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux_vm[tonumber(split("-", each.key)[1])].id : azurerm_windows_virtual_machine.windows_vm[tonumber(split("-", each.key)[1])].id
  lun                = split("-", each.key)[0]
  caching            = "ReadWrite"
}
