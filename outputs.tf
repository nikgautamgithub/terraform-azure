output "vm_ids" {
  value = module.azure_vm[*].vm_ids
}