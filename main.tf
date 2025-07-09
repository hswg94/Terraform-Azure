# Create a resource group
resource "azurerm_resource_group" "testproject-rg" {
  name     = "testproject-rg"
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
  name                 = "testproject-agw-subnet"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "testproject-vmss-subnet" {
  name                 = "testproject-vmss-subnet"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
