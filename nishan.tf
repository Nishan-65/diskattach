provider "azurerm" {
  alias = "nishan"
  features {}
}

resource "azurerm_resource_group" "rgp" {
  name     = "nishan"
  location = "centralindia"
}

resource "azurerm_virtual_network" "virnet" {
  name                = "vnet-001"
  resource_group_name = azurerm_resource_group.rgp.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgp.location
}

resource "azurerm_subnet" "sub" {
  name                 = "sbnet01"
  resource_group_name  = azurerm_resource_group.rgp.name
  virtual_network_name = azurerm_virtual_network.virnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsgs" {
  name                = "nsg-001"
  resource_group_name = azurerm_resource_group.rgp.name
  location            = azurerm_resource_group.rgp.location

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "ncard" {
  name                = "ncard01"
  resource_group_name = azurerm_resource_group.rgp.name
  location            = azurerm_resource_group.rgp.location

  ip_configuration {
    name                          = "ip-01"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "my_nsg" {
  network_interface_id      = azurerm_network_interface.ncard.id
  network_security_group_id = azurerm_network_security_group.nsgs.id
}

resource "random_id" "random_id" {
  byte_length = 8
}

resource "azurerm_storage_account" "strg" {
  name                     = "strg1"
  resource_group_name      = azurerm_resource_group.rgp.name
  account_tier             = "Standard"
  location                 = azurerm_resource_group.rgp.location
  account_replication_type = "LRS"
}

resource "azurerm_public_ip" "pubip" {
  name                = "pubips"
  resource_group_name = azurerm_resource_group.rgp.name
  allocation_method   = "Static"
  location            = azurerm_resource_group.rgp.location

}

resource "azurerm_windows_virtual_machine" "virt" {
  name                  = "demovm-01"
  location              = azurerm_resource_group.rgp.location
  resource_group_name   = azurerm_resource_group.rgp.name
  network_interface_ids = [azurerm_network_interface.ncard.id]
  size                  = "Standard_B1s"
  admin_username        = "nishan"
  admin_password        = "udupi@123456"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-DataCenter"
    version   = "latest"
  }

  os_disk {
    name                 = "os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.strg.primary_blob_endpoint
  }
}

