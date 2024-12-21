# subscription_1_id = "00000000-0000-0000-0000-000000000000"
# subscription_2_id = "11111111-1111-1111-1111-111111111111"

resource_definitions = [
  {
    type              = "vm"
    subscription_name = "sub_1"           # Matches provider alias
    name              = "myLinuxVM"
    os_type           = "Linux"
    vm_size           = "Standard_B2s"
    resource_group    = "rg-demo"
  },
  {
    type              = "vm"
    subscription_name = "sub_2"
    name              = "myWindowsVM"
    os_type           = "Windows"
    vm_size           = "Standard_B2s"
    resource_group    = "rg-demo"
  },
  # Add entries for AKS, Storage Accounts, etc.
]
