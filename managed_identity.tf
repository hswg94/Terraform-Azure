# User Assigned Managed Identity for DevOps
resource "azurerm_user_assigned_identity" "mi-ppl-uat-devops" {
  name                = "mi-ppl-uat-devops"
  resource_group_name = azurerm_resource_group.newproject-rg.name
  location            = azurerm_resource_group.newproject-rg.location
  tags                = {}
}
