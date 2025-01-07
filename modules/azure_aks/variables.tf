# Basic Cluster Configuration
variable "cluster_name" {
  type        = string
  description = "The name of the AKS cluster"
}

variable "region" {
  type        = string
  description = "The location/region where the AKS cluster will be created"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes"
}

# System Node Pool Configuration
variable "system_node_pool_name" {
  type        = string
  description = "The name of the system node pool"
  default     = "systempool"
}

variable "system_node_count" {
  type        = number
  description = "Number of nodes in the system node pool"
  default     = 1
}

variable "system_node_vm_size" {
  type        = string
  description = "The size of the system node VMs"
  default     = "Standard_D2s_v3"
}

variable "system_node_pool_type" {
  type        = string
  description = "The type of the system node pool"
  default     = "VirtualMachineScaleSets"
}

variable "system_node_disk_size" {
  type        = number
  description = "The size of the OS disk in GB"
  default     = 128
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable auto scaling for the system node pool"
  default     = false
}

variable "system_node_min_count" {
  type        = number
  description = "Minimum number of nodes for auto scaling"
  default     = 1
}

variable "system_node_max_count" {
  type        = number
  description = "Maximum number of nodes for auto scaling"
  default     = 3
}

# User Node Pool Configuration
variable "enable_user_node_pool" {
  type        = bool
  description = "Enable creation of user node pool"
  default     = true
}

variable "user_node_pool_name" {
  type        = string
  description = "The name of the user node pool"
  default     = "userpool"
}

variable "user_node_count" {
  type        = number
  description = "Number of nodes in the user node pool"
  default     = 1
}

variable "user_node_vm_size" {
  type        = string
  description = "The size of the user node VMs"
  default     = "Standard_D2s_v3"
}

variable "user_node_disk_size" {
  type        = number
  description = "The size of the OS disk in GB for user nodes"
  default     = 128
}

variable "enable_user_auto_scaling" {
  type        = bool
  description = "Enable auto scaling for the user node pool"
  default     = false
}

variable "user_node_min_count" {
  type        = number
  description = "Minimum number of nodes for user pool auto scaling"
  default     = 1
}

variable "user_node_max_count" {
  type        = number
  description = "Maximum number of nodes for user pool auto scaling"
  default     = 3
}

# Shared Node Configuration
variable "os_sku" {
  type        = string
  description = "The OS SKU to use for the nodes"
  default     = "Ubuntu"
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of Availability Zones to spread nodes across"
  default     = []
}

# Network Configuration
variable "network_plugin" {
  type        = string
  description = "Network plugin to use for networking"
  default     = "kubenet"
}

variable "network_policy" {
  type        = string
  description = "Network policy to use for networking"
  default     = "calico"
}

variable "load_balancer_sku" {
  type        = string
  description = "SKU tier for the load balancer"
  default     = "standard"
}

variable "dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery"
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  type        = string
  description = "CIDR notation IP range assigned to the Docker bridge"
  default     = "172.17.0.1/16"
}

variable "service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service"
  default     = "10.0.0.0/16"
}

variable "vnet_subnet_id" {
  type        = string
  description = "The ID of the subnet where the nodes will be deployed"
  default     = null
}

# Identity Configuration
variable "identity_type" {
  type        = string
  description = "The type of identity to use"
  default     = "SystemAssigned"
}

# RBAC Configuration
variable "rbac_enabled" {
  type        = bool
  description = "Enable RBAC on the cluster"
  default     = true
}

variable "aad_rbac_enabled" {
  type        = bool
  description = "Enable Azure AD RBAC on the cluster"
  default     = false
}

variable "aad_admin_group_object_ids" {
  type        = list(string)
  description = "Object IDs of Azure AD groups that will have admin access"
  default     = []
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
