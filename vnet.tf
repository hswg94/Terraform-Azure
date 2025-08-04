# Create a Resource Group
resource "azurerm_resource_group" "newproj-rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "newproj-vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.newproj-rg.name
  location            = azurerm_resource_group.newproj-rg.location
  address_space       = var.vnet_address_space
  # DNS servers will be null in UAT, set via prod.tfvars in production
  dns_servers         = var.dns_servers
}

# Application Gateway subnet
resource "azurerm_subnet" "newproj-agw01-subnet" {
  name                 = "sub-${var.project_name}-${var.environment}web-appgw01"
  resource_group_name  = azurerm_resource_group.newproj-rg.name
  virtual_network_name = azurerm_virtual_network.newproj-vnet.name
  address_prefixes     = [var.subnet_cidrs.agw_subnet]

  # Disable default outbound access
  default_outbound_access_enabled = false
}

# Application subnet for VMs
resource "azurerm_subnet" "newproj-app01-subnet" {
  name                 = "sub-${var.project_name}-${var.environment}apt-app01"
  resource_group_name  = azurerm_resource_group.newproj-rg.name
  virtual_network_name = azurerm_virtual_network.newproj-vnet.name
  address_prefixes     = [var.subnet_cidrs.app_subnet]

  # Disable default outbound access
  default_outbound_access_enabled = false

  # Service endpoints for storage
  service_endpoints = ["Microsoft.Storage"]
}

# Database subnet for private endpoints
resource "azurerm_subnet" "newproj-db-subnet" {
  name                 = "sub-${var.project_name}-${var.environment}dbt-dbs01"
  resource_group_name  = azurerm_resource_group.newproj-rg.name
  virtual_network_name = azurerm_virtual_network.newproj-vnet.name
  address_prefixes     = [var.subnet_cidrs.db_subnet]

  # Disable default outbound access
  default_outbound_access_enabled = false

  # Service endpoints for storage
  service_endpoints = ["Microsoft.Storage"]
}

# Management/Jump Host subnet
resource "azurerm_subnet" "newproj-jh-subnet" {
  name                 = "sub-${var.project_name}-${var.environment}mgt-jh01"
  resource_group_name  = azurerm_resource_group.newproj-rg.name
  virtual_network_name = azurerm_virtual_network.newproj-vnet.name
  address_prefixes     = [var.subnet_cidrs.jh_subnet]

  # Disable default outbound access
  default_outbound_access_enabled = false
}