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
