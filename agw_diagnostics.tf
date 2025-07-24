# Diagnostic Settings for Application Gateway
resource "azurerm_monitor_diagnostic_setting" "agw-diagnostics" {
  name               = "apgw-ppl-uatweb-ag-diag01"
  target_resource_id = azurerm_application_gateway.apgw-ppl-uatweb-ag.id

  # Application Gateway Access Log
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  # Application Gateway Firewall Log
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  # Send to existing Log Analytics Workspace (reference to cross-subscription)
  log_analytics_workspace_id = "/subscriptions/404d7eec-c082-4873-9853-f4e8f0ed9697/resourceGroups/rg-aclcen-int/providers/Microsoft.OperationalInsights/workspaces/law-aclcen-intmgt-cmn-01"
  log_analytics_destination_type = "Dedicated"
}