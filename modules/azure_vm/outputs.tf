output "vm_ids" {
  value = [azurerm_linux_virtual_machine.linux_vm[*].id, azurerm_windows_virtual_machine.windows_vm[*].id]
}
