output "vm_ids" {
  value = [for vm in var.resource_definitions : module.azure_vm.vm_id if vm["type"] == "vm"]
}
