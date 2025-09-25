terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
     version = "1.10.3"
    }
  }
}

# Details voor de provider
provider "esxi" {
  esxi_hostname = "192.168.1.9"      # Vul hier jouw ESXi IP nummer in
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = "Welkom01!"
}

resource "esxi_guest" "labopdracht1" {
  guest_name  = "labopdracht1"
  disk_store  = "Datastore1"

  # Let op: controleer of deze URL klopt en beschikbaar is
  ovf_source  = "https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.ova"

  memsize     = "1024"
  numvcpus    = "1"

  network_interfaces {
    virtual_network = "VM Network"
  }
}
