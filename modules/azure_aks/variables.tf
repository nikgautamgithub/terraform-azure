variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
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

variable "vnet_subnet_id" {
  description = "ID of the existing subnet"
  type        = string
}

variable "service_cidr" {
  description = "Kubernetes service address range"
  type        = string
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP address"
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
    zones           = list(string)
    mode            = string
    os_sku          = string
    vnet_subnet_id  = string
  })

  validation {
    condition     = var.default_node_pool.mode == "System"
    error_message = "The default node pool mode must be 'System'."
  }

  validation {
    condition     = contains(["Linux", "Ubuntu"], var.default_node_pool.os_sku)
    error_message = "The default node pool OS SKU must be either 'Linux' or 'Ubuntu'."
  }
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
    zones           = list(string)
    mode            = string
    os_sku          = string
    vnet_subnet_id  = string
  }))
}

variable "tags" {
  description = "Tags to be applied to the Event Hub Namespace"
  type        = map(string)
  default     = {}
}
