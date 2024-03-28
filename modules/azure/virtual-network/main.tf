locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.cidr]
  tags                = merge(var.tags, local.dd_tags)
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.name}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.cidr]
}

resource "azurerm_nat_gateway" "natgw" {
  name                = "ng-${var.name}"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "natgw_ip" {
  name                = "pip-ng-${var.name}"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  location            = azurerm_virtual_network.vnet.location
  sku                 = "Standard"
  sku_tier            = "Regional"
  ip_version          = "IPv4"
  allocation_method   = "Static"
  tags                = merge(var.tags, local.dd_tags)
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_natgw_assoc" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}
