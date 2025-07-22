# Create a resource group
resource "azurerm_resource_group" "testproject-rg" {
  name     = "william-testproject-rg"
  location = "Southeast Asia"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "testproject-vnet" {
  name                = "testproject-vnet"
  resource_group_name = azurerm_resource_group.testproject-rg.name
  location            = azurerm_resource_group.testproject-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "testproject-agw-subnet" {
  name                 = "testproject-agw"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "testproject-vmss-subnet" {
  name                 = "testproject-vmss"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "agw-nsg-association" {
  subnet_id                 = azurerm_subnet.testproject-agw-subnet.id
  network_security_group_id = azurerm_network_security_group.testproject-agw-subnet-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "vmss-nsg-association" {
  subnet_id                 = azurerm_subnet.testproject-vmss-subnet.id
  network_security_group_id = azurerm_network_security_group.testproject-vmss-subnet-nsg.id
}
