# /* Frontend resource
# fe-rg (resource group)
# pub-ip356 (public IP)
# fe-vnet (virtual network with 2 subnet)
#     firewall subnet
#     application subnet
# fw-356 (firewall)
# */
terraform {
    required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = "=2.20.0"
      }
    } 
 backend "azurerm" {
  storage_account_name = "__terraformstorageaccount__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
	access_key  ="__storagekey__"
  features{}
	}
	}
provider "azurerm" {
    features {}
}
resource "azurerm_resource_group" "fe-rg" {
  name     = "anhnh-fe-rg"
  location = "southeastasia"
}

resource "azurerm_virtual_network" "fe-rg" {
  name                = "fe-vnet"
  address_space       = ["172.16.0.0/23"]
  location            = azurerm_resource_group.fe-rg.location
  resource_group_name = azurerm_resource_group.fe-rg.name
}

resource "azurerm_subnet" "fe-rg-01" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fe-rg.name
  virtual_network_name = azurerm_virtual_network.fe-rg.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet" "fe-rg-02" {
  name                 = "ApplicationSubnet"
  resource_group_name  = azurerm_resource_group.fe-rg.name
  virtual_network_name = azurerm_virtual_network.fe-rg.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_public_ip" "fe-rg" {
  name                = "pub-ip356"
  location            = azurerm_resource_group.fe-rg.location
  resource_group_name = azurerm_resource_group.fe-rg.name
  sku = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_firewall" "fe-rg" {
  name                = "fw-01"
  location            = azurerm_resource_group.fe-rg.location
  resource_group_name = azurerm_resource_group.fe-rg.name
  ip_configuration {
    name                 = "fwip-config"
    subnet_id            = azurerm_subnet.fe-rg-01.id
    public_ip_address_id = azurerm_public_ip.fe-rg.id
  }
}