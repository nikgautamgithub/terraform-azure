locals {
  # For zonal deployments
  zonal_disks = length(var.zones) > 0 ? {
    for pair in setproduct(range(length(var.data_disk_sizes)), range(length(var.zones))) :
    "${pair[0]}-${pair[1]}" => {
      size      = var.data_disk_sizes[pair[0]]
      zone      = var.zones[pair[1]]
      disk_type = var.data_disk_types[pair[0]]
    }
  } : null

  # For non-zonal deployments
  non_zonal_disks = length(var.zones) == 0 ? {
    for idx in range(length(var.data_disk_sizes)) :
    "${idx}-0" => {
      size      = var.data_disk_sizes[idx]
      disk_type = var.data_disk_types[idx]
      zone      = null
    }
  } : null

  # Final disk configuration
  final_disk_config = length(var.zones) > 0 ? local.zonal_disks : local.non_zonal_disks
}

# First, add a local to split the image reference
locals {
  # Split the OS image string into components
  image_parts = split(":", var.os_image)

  # Create a map for source_image_reference
  source_image = {
    publisher = local.image_parts[0]
    offer     = local.image_parts[1]
    sku       = local.image_parts[2]
    version   = local.image_parts[3]
  }
}

locals {
  os_image_id = "/subscriptions/6e47c803-d4a0-49b2-9b1f-01500ce57b80/resourceGroups/my-rg/providers/Microsoft.Compute/galleries/mygallery/images/myimagedef/versions/1.0.0"
}

resource "azurerm_public_ip" "vm_public_ip" {
  count               = var.public_ip_required == "yes" ? length(var.zones) : 0
  name                = length(var.zones) == 1 ? "${var.vm_name}-public-ip" : "${var.vm_name}-${count.index + 1}-public-ip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(var.zones) > 0 ? [var.zones[count.index]] : null
}

resource "azurerm_network_interface" "vm_nic" {
  count               = length(var.zones) > 0 ? length(var.zones) : 1
  name                = length(var.zones) <= 1 ? "${var.vm_name}-nic" : "${var.vm_name}-${count.index + 1}-nic"
  location            = var.region
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
  count                     = length(var.zones) > 0 ? length(var.zones) : 1
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = data.azurerm_network_security_group.existing_nsg.id

  depends_on = [
    azurerm_network_interface.vm_nic,
    data.azurerm_network_security_group.existing_nsg
  ]
}

resource "azurerm_managed_disk" "data_disks" {
  for_each             = local.final_disk_config
  name                 = "${var.vm_name}-disk-${each.key}"
  location             = var.region
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.disk_type
  create_option        = "Empty"
  disk_size_gb         = tonumber(each.value.size)
  zone                 = each.value.zone
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  count               = var.os_type == "Linux" ? (length(var.zones) > 0 ? length(var.zones) : 1) : 0
  name                = length(var.zones) <= 1 ? var.vm_name : "${var.vm_name}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = length(var.zones) > 0 ? var.zones[count.index] : null

  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.vm_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }

  source_image_reference {
    publisher = local.source_image.publisher
    offer     = local.source_image.offer
    sku       = local.source_image.sku
    version   = local.source_image.version
  }

  depends_on = [
    azurerm_network_interface.vm_nic,
    azurerm_network_interface_security_group_association.nic_nsg_association
  ]
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count               = var.os_type == "Windows" ? (length(var.zones) > 0 ? length(var.zones) : 1) : 0
  name                = length(var.zones) <= 1 ? var.vm_name : "${var.vm_name}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = length(var.zones) > 0 ? var.zones[count.index] : null

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

  depends_on = [
    azurerm_network_interface.vm_nic,
    azurerm_network_interface_security_group_association.nic_nsg_association
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachments" {
  for_each        = local.final_disk_config
  managed_disk_id = azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = var.os_type == "Linux" ? (
    length(var.zones) > 0 ?
    azurerm_linux_virtual_machine.linux_vm[tonumber(split("-", each.key)[1])].id :
    azurerm_linux_virtual_machine.linux_vm[0].id
    ) : (
    length(var.zones) > 0 ?
    azurerm_windows_virtual_machine.windows_vm[tonumber(split("-", each.key)[1])].id :
    azurerm_windows_virtual_machine.windows_vm[0].id
  )
  lun     = tonumber(split("-", each.key)[0])
  caching = "ReadWrite"

  depends_on = [
    azurerm_linux_virtual_machine.linux_vm,
    azurerm_windows_virtual_machine.windows_vm,
    azurerm_managed_disk.data_disks
  ]
}
