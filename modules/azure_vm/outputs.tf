output "vm_id" {
  value = [
    azurerm_linux_virtual_machine.vm[*].id,
    azurerm_windows_virtual_machine.vm[*].id
  ]
}
