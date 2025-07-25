# Public IP for NAT Gateway
resource "azurerm_public_ip" "pip-ppl-natgw01" {
  name                = "pip-${var.project_name}-${var.environment}-natgw01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# NAT Gateway
resource "azurerm_nat_gateway" "natgw-ppl" {
  name                    = "natgw-${var.environment}-${var.project_name}"
  location                = azurerm_resource_group.newproj-rg.location
  resource_group_name     = azurerm_resource_group.newproj-rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "natgw-pip-association" {
  nat_gateway_id       = azurerm_nat_gateway.natgw-ppl.id
  public_ip_address_id = azurerm_public_ip.pip-ppl-natgw01.id
}