terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "3969c339-e73e-49f2-97f3-e499491b910a"
}

# Gebruik de bestaande resource group iac-rg
data "azurerm_resource_group" "iac_rg" {
  name = "iac-rg"
}

# Virtual Network
resource "azurerm_virtual_network" "lablb_vnet" {
  name                = "lablb-vnet"
  location            = "swedencentral"
  resource_group_name = data.azurerm_resource_group.iac_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "lablb_subnet" {
  name                 = "lablb-subnet"
  resource_group_name  = data.azurerm_resource_group.iac_rg.name
  virtual_network_name = azurerm_virtual_network.lablb_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG met SSH-poort open
resource "azurerm_network_security_group" "lablb_nsg" {
  name                = "lablb-nsg"
  location            = "swedencentral"
  resource_group_name = data.azurerm_resource_group.iac_rg.name

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

# Public IP (Standard SKU)
resource "azurerm_public_ip" "lablb_pip" {
  name                = "lablb-pip"
  location            = "swedencentral"
  resource_group_name = data.azurerm_resource_group.iac_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "lablb_nic" {
  name                = "lablb-nic"
  location            = "swedencentral"
  resource_group_name = data.azurerm_resource_group.iac_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lablb_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lablb_pip.id
  }
}

# Koppel NSG aan NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.lablb_nic.id
  network_security_group_id = azurerm_network_security_group.lablb_nsg.id
}

# Ubuntu VM
resource "azurerm_linux_virtual_machine" "lablb_vm" {
  name                = "lablb-vm"
  location            = "swedencentral"
  resource_group_name = data.azurerm_resource_group.iac_rg.name
  network_interface_ids = [
    azurerm_network_interface.lablb_nic.id
  ]
  size           = "Standard_DS1_v2"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
