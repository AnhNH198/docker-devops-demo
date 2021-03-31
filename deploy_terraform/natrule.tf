resource "azurerm_virtual_network_peering" "fe-be" {
  name                      = "fe-be"
  resource_group_name       = azurerm_resource_group.fe-rg.name
  virtual_network_name      = azurerm_virtual_network.fe-rg.name
  remote_virtual_network_id = azurerm_virtual_network.be-rg.id
}

resource "azurerm_virtual_network_peering" "be-fe" {
  name                      = "be-fe"
  resource_group_name       = azurerm_resource_group.be-rg.name
  virtual_network_name      = azurerm_virtual_network.be-rg.name
  remote_virtual_network_id = azurerm_virtual_network.fe-rg.id
}

resource "azurerm_firewall_nat_rule_collection" "fe-rg" {
  name                = "nat01"
  azure_firewall_name = azurerm_firewall.fe-rg.name
  resource_group_name = azurerm_resource_group.fe-rg.name
  priority            = 100
  action              = "Dnat"
  rule {
    name = "web-rule"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "80",
    ]
    destination_addresses = [
      azurerm_public_ip.fe-rg.ip_address
    ]
    translated_port    = 8000
    translated_address = azurerm_network_interface.be-rg.private_ip_address
    protocols = [
      "TCP",
    ]
  }
  rule {
    name = "jbox-rule"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "22",
    ]
    destination_addresses = [
      azurerm_public_ip.fe-rg.ip_address
    ]
    translated_port    = 22
    translated_address = azurerm_network_interface.be-rg.private_ip_address
    protocols = [
      "TCP",
    ]
  }
}