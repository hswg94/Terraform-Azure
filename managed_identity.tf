# User Assigned Managed Identity for DevOps
resource "azurerm_user_assigned_identity" "mi-ppl-uat-devops" {
  name                = "mi-${var.project_name}-${var.environment}-devops"
  resource_group_name = azurerm_resource_group.newproj-rg.name
  location            = azurerm_resource_group.newproj-rg.location
  tags                = {}
}
