resource "azurerm_resource_group" "aks-rg" {
  count = var.existing_resource_group_name != "" ? 0 : 1
  name = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  count = var.existing_vnet_subnet_id != "" ? 0 : 1
  name = "${var.prefix}-network-aks"
  address_space = var.vnet_address_space
  resource_group_name = azurerm_resource_group.aks-rg[0].name
  location = azurerm_resource_group.aks-rg[0].location
}

resource "azurerm_subnet" "subnet" {
  count = var.existing_vnet_subnet_id != "" ? 0 : 1
  name = "${var.prefix}-subnet-aks"
  address_prefixes = var.aks_address_prefix
  resource_group_name = azurerm_resource_group.aks-rg[0].name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
}

resource "azurerm_subnet_network_security_group_association" "aks-nsg-association" {
  count = var.existing_vnet_subnet_id != "" ? 0 : 1
  subnet_id = azurerm_subnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.security_group_epiphany[0].id
}
resource azurerm_network_security_group "security_group_epiphany" {
  count = var.existing_vnet_subnet_id != "" ? 0 : 1
  name = "aks-1-nsg"
  location = azurerm_resource_group.aks-rg[0].location
  resource_group_name = azurerm_resource_group.aks-rg[0].name

  security_rule {
    name = "ssh"
    description = "Allow SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "0.0.0.0/0"
    destination_address_prefix = "0.0.0.0/0"
  }
}