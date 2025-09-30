terraform {
  required_version = ">= 1.10.3"
  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "1.10.3"
    }
  }
}

provider "esxi" {
  esxi_hostname = "192.168.1.9"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = "Welkom01!"
}

locals {
  templatevars = {
    public_key   = var.public_key
    ssh_username = var.ssh_username
  }
}

# Eén nieuwe VM (veilig, unieke naam)
resource "esxi_guest" "studentvm" {
  guest_name = "student-vm-terraformsz"
  disk_store = var.disk_store
  memsize    = var.memory_mb
  numvcpus   = var.num_cpus
  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.network
  }

  guestinfo = {
    "userdata"          = base64encode(templatefile("${path.module}/userdata.yaml", local.templatevars))
    "userdata.encoding" = "base64"
  }
}

# Output IP
output "studentvm_ip" {
  value = esxi_guest.studentvm.ip_address
}

# Test push trigger
