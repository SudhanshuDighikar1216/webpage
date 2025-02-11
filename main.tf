provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

# Create a storage account (Adding storage_account_type)
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"  # Must be globally unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"  # Specifies the pricing tier (Standard or Premium)
  account_replication_type = "LRS"  # Specifies replication type (LRS, GRS, RA-GRS, etc.)
  storage_account_type     = "Standard_LRS"  # Corrected: Specifies the type of storage account
}

# Create a subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Create a public IP address
resource "azurerm_public_ip" "example" {
  name                         = "example-public-ip"
  location                     = azurerm_resource_group.example.location
  resource_group_name          = azurerm_resource_group.example.name
  allocation_method            = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Create a Linux Virtual Machine (Correcting os_disk configuration)
resource "azurerm_linux_virtual_machine" "example" {
  name                             = "example-vm"
  resource_group_name              = azurerm_resource_group.example.name
  location                         = azurerm_resource_group.example.location
  size                             = "Standard_B1s"
  admin_username                   = "adminuser"
  admin_password                   = "P@ssw0rd1234!"
  network_interface_ids            = [azurerm_network_interface.example.id]
  
  os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    disk_size_gb      = 30
    # Removed invalid 'create_option' attribute
    managed           = true  # Optional, as managed disks are the default
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}
