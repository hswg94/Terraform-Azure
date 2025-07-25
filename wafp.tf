resource "azurerm_web_application_firewall_policy" "wafp-ppl-uatweb-apgw" {
  name                = "wafp-ppl-uatweb-apgw"
  resource_group_name = azurerm_resource_group.newproj-rg.name
  location            = azurerm_resource_group.newproj-rg.location

  policy_settings {
    enabled                     = true
    mode                        = "Detection"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    request_body_enforcement    = true
    request_body_inspect_limit_in_kb = 128
    file_upload_enforcement     = true
    file_upload_limit_in_mb     = 100
    js_challenge_cookie_expiration_in_minutes = 30
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}