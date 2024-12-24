output "vm_ids" {
  value = [azurerm_linux_virtual_machine.linux_vm[*].id]
}
