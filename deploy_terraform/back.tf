/*
be-rg (resource group)
web-vnet (virtualnetwork)
    web-subnet (subnet for web)
web-interface (Network Interface Card)
web-nsg (Network Security Group)
web-vm (Virtual machine to run web)
*/

resource "azurerm_resource_group" "be-rg" {
  name     = "anhnh-be-rg"
  location = "southeastasia"
}

resource "azurerm_virtual_network" "be-rg" {
  name                = "web-vnet"
  address_space       = ["172.16.2.0/23"]
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name
}

resource "azurerm_subnet" "be-rg" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.be-rg.name
  virtual_network_name = azurerm_virtual_network.be-rg.name
  address_prefix     = ["172.16.2.0/24"]
}

resource "azurerm_network_interface" "be-rg" {
  name                = "web-nic"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.be-rg.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_security_group" "be-rg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name
}

resource "azurerm_network_security_rule" "be-rg" {
  name                        = "web"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8000"
  source_address_prefix       = "*"
  destination_address_prefix  = "${azurerm_network_interface.be-rg.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = azurerm_network_security_group.be-rg.name
}

resource "azurerm_network_security_rule" "be-rg-01" {
  name                        = "ssh-web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "${azurerm_network_interface.be-rg.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = azurerm_network_security_group.be-rg.name
}

resource "azurerm_network_interface_security_group_association" "be-rg" {
  network_interface_id      = azurerm_network_interface.be-rg.id
  network_security_group_id = azurerm_network_security_group.be-rg.id
}

resource "azurerm_virtual_machine" "be-rg" {
  name                  = "web-vm01"
  location              = azurerm_resource_group.be-rg.location
  resource_group_name   = azurerm_resource_group.be-rg.name
  network_interface_ids = [azurerm_network_interface.be-rg.id]
  vm_size               = "Standard_B1ls"
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "web-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }
  os_profile {
    computer_name  = "Web-vm01"
    admin_username = "testadmin"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/testadmin/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5f70pdC+P5yaHIn1zv/RgqQUAfKL53tzjZKhiCHajkcJKkvolX8BztxBKbNXNvIKAqikOoAuuF19F1SwLH1vbFuOBYjSKO46hIvPAlzMQgtz1NizMXufYxKzTXGqGajs2bF1qzA878vmg1xnNVDkE8B37tSiknD1WqzoekcA6Bfi5xxp7pgYr1qFYmO4PuP0dUaGeYcnS63fzUFhFmRFtURwbO0b4J2CxCTtpflcQFqXN6xnaeMpJEqgpS8FtwJRfmRd3wE6MGIqy/orNalhw5pKsSr86jusdHWD2x2Xp3ICG+KkbUWOKE9hpLLzzDK4wX6r6bje19miTZxzgUABUZKtOi+FFCOo3Gdzhz3ZfJc1lCzxv42MfaQN3Vn7RI7VJ2HWPIA59QVbDskvkHp5sVs4nZ15tt+Vy/Qd2kqFUug9JhtMfyQRHY0N8uroT3k7s88s/LFRWAULQv+llrQQzRtjDs4LQK9G7V7L2vXpNEDWt52GZCsiqMFmVcPJvXkLkMB+8tW0idgznkcNk04SpPjfIFPpXJmWxmQjybXzsQi6oC9fvN84IEktNO8rEbzH3oI9tdyCDS2Q3/JmAcAQTDojCTJLr2j9ZA9iQx6cCwlvNy2CB3pPu3tRg77ZvXjt84i0eDn5hZcoAmlcvy+mODkmNl3TX5onYHAO3lWAD2Q== boploi198@gmail.com"
    }
  }
}
