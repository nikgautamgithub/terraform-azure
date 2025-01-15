variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "sku_tier" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure Active Directory that manages the Key Vault."
  type        = string
}

variable "default_node_pool" {
  type = object({
    name            = string
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    node_labels     = map(string)
    node_taints     = list(string)
  })
}

variable "additional_node_pools" {
  type = map(object({
    vm_size         = string
    node_count      = number
    min_count       = number
    max_count       = number
    os_disk_size_gb = number
    node_labels     = map(string)
    node_taints     = list(string)
  }))
}
