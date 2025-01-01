subscription_id = "6e47c803-d4a0-49b2-9b1f-01500ce57b80"

resource_definitions = [
  {
    vm_name             = "windows-vm-01",
    resource_group_name = "my-rg",
    os_type             = "Windows",
    os_disk_image       = "/subscriptions/6e47c803-d4a0-49b2-9b1f-01500ce57b80/resourceGroups/my-rg/providers/Microsoft.Compute/galleries/mygallery/images/mywindowsimagedefinition/versions/1.0.0",
    os_disk_type        = "Premium_LRS",
    os_disk_size        = "127",
    vm_size             = "Standard_B2s",
    location            = "UAE North",
    zones               = [],
    nsg_name            = "linux-nsg-01",
    vnet_name           = "linux-vnet-01",
    subnet_name         = "subnet-01",
    ports               = ["22", "443"],
    public_ip_required  = "no",
    data_disk_sizes     = ["64", "128"],
    data_disk_types     = ["Standard_LRS", "Premium_LRS"],
    admin_username      = "azureadmin2",
    admin_password      = "P@ssword123!2",
    type                = "vm",
  },
]
