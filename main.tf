# Beware of Azure Naming convention, see https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.rg_base_name}"
  location = var.rg_location

  tags = {
      Environment = "Terraform Created Environment"
      Team = "SOC/IRC"
  }  
}

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "win10-flare"
  resource_group_name = "rg_irc-excercise-prep"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.rg_base_name}"
  address_space       = ["10.105.0.0/16"]
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet - 105=i, 99=c
resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.rg_base_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.105.99.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  count               = var.vm_count
  name                = "pip-${format(var.vm_base_name, count.index + 1)}"
  domain_name_label   = format(var.vm_base_name, count.index + 1)
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.rg_base_name}"
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name

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

  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "nic-${format(var.vm_base_name, count.index + 1)}"
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-ipcfg-${format(var.vm_base_name, count.index + 1)}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = element(azurerm_public_ip.publicip.*.id, count.index)
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "vm-${format(var.vm_base_name, count.index + 1)}"
  location              = var.rg_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "st-dsk-os-${format(var.vm_base_name, count.index + 1)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id = data.azurerm_image.search.id
  }

  os_profile {
    computer_name  = format(var.vm_base_name, count.index + 1)
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
  }

  os_profile_windows_config {
  }
}

data "azurerm_public_ip" "ip" {
  count               = var.vm_count
  name                = element(azurerm_public_ip.publicip.*.name, count.index)
  resource_group_name = azurerm_virtual_machine.vm[count.index].resource_group_name
  depends_on          = [azurerm_virtual_machine.vm]
}