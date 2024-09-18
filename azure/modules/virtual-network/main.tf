locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.cidr]
  tags                = merge(var.tags, local.dd_tags)
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 2, 0)]
}

resource "azurerm_nat_gateway" "natgw" {
  name                = "natgw"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  sku_name            = "Standard"
  tags                = merge(var.tags, local.dd_tags)
}

resource "azurerm_public_ip" "natgw_ip" {
  name                = "natgw-ip"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
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
  subnet_id      = azurerm_subnet.default_subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

# Bastion (optional)
resource "azurerm_bastion_host" "bastion" {
  count = var.bastion == true ? 1 : 0

  name                = "bastion"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip[count.index].id
  }
  sku               = "Standard"
  tunneling_enabled = true
  tags              = merge(var.tags, local.dd_tags)
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.cidr, 2, 1)]
}

resource "azurerm_public_ip" "bastion_ip" {
  count = var.bastion == true ? 1 : 0

  name                = "bastion-ip"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"
  ip_version          = "IPv4"
  allocation_method   = "Static"
  tags                = merge(var.tags, local.dd_tags)
}
