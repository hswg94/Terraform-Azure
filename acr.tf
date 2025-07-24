# Azure Container Registry
resource "azurerm_container_registry" "acrppluat" {
  name                = "acrppluat"
  resource_group_name = azurerm_resource_group.newproject-rg.name
  location            = azurerm_resource_group.newproject-rg.location
  sku                 = "Standard"
  admin_enabled       = true

  # Network access (default is enabled for Standard SKU)
  public_network_access_enabled = true

  tags = {}
}