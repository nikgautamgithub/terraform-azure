variable "name" {
  description = "Name of the App Service"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "publish" {
  description = "Publish type (Code or Docker)"
  type        = string
  default     = "Code"
  validation {
    condition     = contains(["Code", "Docker"], var.publish)
    error_message = "Publish type must be either Code or Docker."
  }
}

variable "os_type" {
  description = "Operating System type"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "pricing_plan" {
  description = "Pricing plan for the App Service Plan"
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  type        = string
  default     = null
}

variable "pe_subnet_id" {
  description = "Name of the subnet"
  type        = string
}

variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "runtime_stack" {
  description = "The type of runtime stack"
  type        = string
  validation {
    condition     = contains(["dotnet", "go", "java", "node", "php", "python", "ruby", "docker"], var.runtime_stack)
    error_message = "Runtime stack must be one of: dotnet, go, java, node, php, python, ruby, docker."
  }
}

variable "runtime_version" {
  description = "Version of the runtime stack"
  type        = string
  default     = null
}

variable "java_server" {
  description = "The Java server type (required if runtime_stack is java)"
  type        = string
  default     = null
  validation {
    condition     = var.java_server == null ? true : contains(["JAVA", "TOMCAT", "JBOSSEAP"], var.java_server)
    error_message = "Java server must be one of: JAVA, TOMCAT, JBOSSEAP."
  }
}

variable "java_server_version" {
  description = "The Version of the java_server"
  type        = string
  default     = null
}

variable "docker_image" {
  description = "The docker image name including tag"
  type        = string
  default     = null
}

variable "docker_registry_url" {
  description = "The URL of the container registry"
  type        = string
  default     = null
}

variable "docker_registry_username" {
  description = "The username for docker registry authentication"
  type        = string
  default     = null
}

variable "docker_registry_password" {
  description = "The password for docker registry authentication"
  type        = string
  default     = null
  sensitive   = true
}
