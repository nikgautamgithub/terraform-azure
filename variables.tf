variable "subscription_1_id" {
  type        = string
  description = "Subscription ID for environment 1"
}

variable "subscription_2_id" {
  type        = string
  description = "Subscription ID for environment 2"
}

variable "resource_definitions" {
  type        = list(map(string))
  description = "List of maps containing resource definitions from CSV"
}

variable "location" {
  type        = string
  default     = "eastus"
}

# Add more global variables as needed
