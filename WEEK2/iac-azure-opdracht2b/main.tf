terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource group ophalen via data (niet aanmaken)
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Virtueel netwerk
resource "azurerm_virtual_network" "vnet" {
  name                = "iac-vnet"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "iac-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG met SSH open
resource "azurerm_network_security_group" "nsg" {
  name                = "iac-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP's (Standard SKU!)
resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "iac-public-ip-${count.index}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NIC's
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "iac-nic-${count.index}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "iac-vm-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = "iac"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_ssh_key {
    username   = "iac"
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))
}


# IP-adressen wegschrijven
resource "local_file" "write_ips" {
  filename = "azure-ips.txt"
  content = join("\n", [for vm in azurerm_linux_virtual_machine.vm : vm.public_ip_address])
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "vm_public_ips" {
  value = [for vm in azurerm_linux_virtual_machine.vm : vm.public_ip_address]
}
