variable "public_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBT7pRNo2OcBmWAfgZpAkHKSkA/5EHeAcCyyhCVlPxgL terraform"
}
variable "ssh_username" {
  description = "Gebruikersnaam voor alle VM's"
  type        = string
  default     = "student"
}

variable "memory_mb" {
  description = "RAM grootte per VM"
  type        = number
  default     = 2048
}

variable "num_cpus" {
  description = "Aantal vCPU's per VM"
  type        = number
  default     = 1
}

variable "disk_store" {
  description = "Naam van de datastore op ESXi"
  type        = string
  default     = "Datastore1"
}

variable "ovf_source" {
  description = "Pad naar de website ubunutu ISO"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"
}


variable "network" {
  description = "Virtueel netwerk in ESXi"
  type        = string
  default     = "VM Network"
}
