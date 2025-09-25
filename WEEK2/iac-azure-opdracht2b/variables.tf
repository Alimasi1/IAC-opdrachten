variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "3969c339-e73e-49f2-97f3-e499491b910a"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "iac-rg"
}

variable "location" {
  description = "Azure location (moet hetzelfde zijn als je resource group)"
  type        = string
  default     = "swedencentral" # Pas aan naar de regio van je resource group
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Azure VM size (fallback = Standard_B1s)"
  type        = string
  default     = "Standard_B1s"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/azure_rsa.pub"
}
