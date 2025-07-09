
resource "azurerm_network_security_group" "testproject-agw-subnet-nsg" {
  name                = "testproject-agw-subnet-nsg"
  location            = azurerm_resource_group.testproject-rg.location
  resource_group_name = azurerm_resource_group.testproject-rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.testproject-agw-subnet.address_prefixes[0]
  }

  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_network_security_group" "testproject-vmss-subnet-nsg" {
  name                = "testproject-vmss-subnet-nsg"
  location            = azurerm_resource_group.testproject-rg.location
  resource_group_name = azurerm_resource_group.testproject-rg.name

  security_rule {
    name                       = "AllowAppPort3000"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = azurerm_subnet.testproject-agw-subnet.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.testproject-vmss-subnet.address_prefixes[0]
  }

    security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "*"
  }

    security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "3000"
    destination_port_range     = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

