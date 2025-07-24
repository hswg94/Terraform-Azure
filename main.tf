# Create a resource group
resource "azurerm_resource_group" "testproject-rg" {
  name     = "rg-ppl-uat"
  location = "Southeast Asia"
}

# virtual network
resource "azurerm_virtual_network" "testproject-vnet" {
  name                = "vnet-uat-ppl"
  resource_group_name = azurerm_resource_group.testproject-rg.name
  location            = azurerm_resource_group.testproject-rg.location
  address_space       = ["172.18.132.0/24"]
  dns_servers = ["172.18.17.68", "172.18.17.69"]
}

# Application Gateway subnet
resource "azurerm_subnet" "testproject-agw-subnet" {
  name                 = "sub-ppl-uatweb-appgw01"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["172.18.132.0/28"]

  # Disable default outbound access
  default_outbound_access_enabled = false
}

# Application subnet for VMs
resource "azurerm_subnet" "testproject-app-subnet" {
  name                 = "sub-ppl-uatapt-app01"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["172.18.132.16/28"]

  # Disable default outbound access
  default_outbound_access_enabled = false

  # Service endpoints for storage
  service_endpoints = ["Microsoft.Storage"]
}

# Database subnet for private endpoints
resource "azurerm_subnet" "testproject-db-subnet" {
  name                 = "sub-ppl-uatdbt-dbs01"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["172.18.132.48/28"]

  # Disable default outbound access
  default_outbound_access_enabled = false

  # Service endpoints for storage
  service_endpoints = ["Microsoft.Storage"]
}

# Management/Jump Host subnet
resource "azurerm_subnet" "testproject-mgmt-subnet" {
  name                 = "sub-ppl-uatmgt-jh01"
  resource_group_name  = azurerm_resource_group.testproject-rg.name
  virtual_network_name = azurerm_virtual_network.testproject-vnet.name
  address_prefixes     = ["172.18.132.224/28"]

  # Disable default outbound access
  default_outbound_access_enabled = false
}
