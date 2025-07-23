# Since these variables are re-used - a locals block makes this more maintainable
# locals {
#   backend_address_pool_name      = "testproject-agw-backend-pool"
#   frontend_port_name             = "testproject-agw-frontend-port"
#   frontend_ip_configuration_name = "testproject-agw-frontend-ip-configuration"
#   http_setting_name              = "testproject-agw-backend-http-setting"
#   listener_name                  = "testproject-agw-http-listener"
#   request_routing_rule_name      = "testproject-agw-routing-rule"
#   redirect_configuration_name    = "testproject-agw-redirect-configuration"
# }

resource "azurerm_public_ip" "testproject-agw-pip" {
  name                = "pip-ppl-uat-apgw01"
  resource_group_name = azurerm_resource_group.testproject-rg.name
  location            = azurerm_resource_group.testproject-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_application_gateway" "testproject-agw" {
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.testproject-agw-subnet.id
  }

  name                = "apgw-ppl-uatweb-ag"
  resource_group_name = azurerm_resource_group.testproject-rg.name
  location            = azurerm_resource_group.testproject-rg.location
  enable_http2        = true
  zones               = ["1", "2", "3"]

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.ppl-uat-waf.id

  ssl_policy {
    policy_type          = "CustomV2"
    min_protocol_version = "TLSv1_2"
    cipher_suites = [
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
    ]
  }

  backend_address_pool {
    name = "simplicity-app"
  }

  backend_address_pool {
    name = "empty"

  }

  //////// BACKEND SETTINGS ////////
  backend_http_settings {
    name                  = "temp-settings"
    protocol              = "Http"
    port                  = 80
    cookie_based_affinity = "Disabled"
    connection_draining {
      enabled           = false
      drain_timeout_sec = 1
    }
    request_timeout = 20
    # path                                = "/"
    pick_host_name_from_backend_address = false
    # probe_name                          = ""
  }

  backend_http_settings {
    name                  = "simplicity-settings"
    protocol              = "Http"
    port                  = 80
    cookie_based_affinity = "Disabled"
    connection_draining {
      enabled           = false
      drain_timeout_sec = 1
    }
    request_timeout = 2000
    # path                                = "/"
    pick_host_name_from_backend_address = false
    # probe_name                          = ""
  }

  backend_http_settings {
    name                  = "sendapi-backendsettings"
    protocol              = "Http"
    port                  = 80
    cookie_based_affinity = "Disabled"
    connection_draining {
      enabled           = false
      drain_timeout_sec = 1
    }
    request_timeout = 1200
    # path                                = "/"
    pick_host_name_from_backend_address = true
    probe_name                          = "sendapi-probe"
  }

  backend_http_settings {
    name                  = "as4-backendsettings"
    protocol              = "Http"
    port                  = 8080
    cookie_based_affinity = "Disabled"
    connection_draining {
      enabled           = false
      drain_timeout_sec = 1
    }
    request_timeout = 1200
    # path                                = "/"
    pick_host_name_from_backend_address = true
    probe_name                          = "as4-probe"
  }

  backend_http_settings {
    name                  = "admin-backendsettings"
    protocol              = "Http"
    port                  = 80
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    connection_draining {
      enabled           = false
      drain_timeout_sec = 1
    }
    request_timeout = 1200
    # path                                = "/"
    pick_host_name_from_backend_address = true
    probe_name                          = "admin-probe"
  }

  //////// END OF BACKEND SETTINGS ////////

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.testproject-agw-pip.id
  }

  //////// FRONTEND PORTS ////////
  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  frontend_port {
    name = "port_8008"
    port = 8008
  }
  //////// END OF FRONTEND PORTS ////////

  //////// SSL CERTIFICATES ////////
  # ssl_certificate {
  #   name     = "wildcard-anacle-com-2024-25"
  #   data     = filebase64("path/to/your/certificate.pfx") # Update this path
  #   password = "your_certificate_password"                # Update this password
  # }
  //////// END OF SSL CERTIFICATES ////////

  //////// LISTENERS ////////
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Http"
    frontend_port_name             = "port_80"
    host_name                      = "invoicenow-ap-uat.anacle.com"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Https"
    frontend_port_name             = "port_443"
    host_name                      = "invoicenow-ap-uat.anacle.com"
    ssl_certificate_name           = "wildcard-anacle-com-2024-25"
    require_sni                    = true
  }

  http_listener {
    name                           = "temp-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Http"
    frontend_port_name             = "port_8008"
  }

  //////// END OF LISTENERS ////////

  //////// ROUTING RULES ////////
  /* HTTP-RULE */
  request_routing_rule {
    name                        = "http-rule"
    priority                    = 10
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-rule"
  }

  redirect_configuration {
    name                 = "http-rule"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  /* END OF HTTP RULE */

  /* HTTPS-RULE */
  request_routing_rule {
    name               = "https-rule"
    priority           = 100
    http_listener_name = "https-listener"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "https-rule"
  }

  url_path_map {
    name                                 = "https-rule"
    default_redirect_configuration_name = "https-rule"

    path_rule {
      paths                      = ["/sendapi/*"]
      name                       = "sendapi"
      backend_http_settings_name = "sendapi-backendsettings"
      backend_address_pool_name  = "simplicity-app"
      rewrite_rule_set_name      = "rws-ppl-uatweb-ag-01"
    }

    path_rule {
      paths                      = ["/admin/*"]
      name                       = "admin"
      backend_http_settings_name = "admin-backendsettings"
      backend_address_pool_name  = "simplicity-app"
      rewrite_rule_set_name      = "rws-ppl-uatweb-ag-01"
    }

    path_rule {
      paths                      = ["/as4*"]
      name                       = "oxalis"
      backend_http_settings_name = "as4-backendsettings"
      backend_address_pool_name  = "simplicity-app"
      rewrite_rule_set_name      = "rws-ppl-uatweb-ag-01"
    }

    path_rule {
      paths                       = ["/as4/"]
      name                        = "redirect-as4"
      redirect_configuration_name = "https-rule_redirect"
      rewrite_rule_set_name       = "rws-ppl-uatweb-ag-01"
    }

    path_rule {
      paths                       = ["/as4/status*"]
      name                        = "redirect-as4-status"
      redirect_configuration_name = "https-rule_redirect-status"
      rewrite_rule_set_name       = "rws-ppl-uatweb-ag-01"
    }
  }

  redirect_configuration {
    name                 = "https-rule_redirect"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = true
    include_query_string = true
  }

  redirect_configuration {
    name                 = "https-rule_redirect-status"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = false
    include_query_string = false
  }

  redirect_configuration {
    name                 = "https-rule_redirect-as4"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = false
    include_query_string = false
  }

  redirect_configuration {
    name                 = "https-rule_redirect-as4-status"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = false
    include_query_string = false
  }

  redirect_configuration {
    name                 = "https-rule"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/admin"
    include_path         = true
    include_query_string = true
  }

  /* END OF HTTPS RULE */

  /* TEMP RULE */

  request_routing_rule {
    name               = "temp-rule"
    priority           = 5000
    http_listener_name = "temp-listener"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "temp-rule"
  }

  url_path_map {
    name                               = "temp-rule"
    default_backend_address_pool_name  = "empty"
    default_backend_http_settings_name = "temp-settings"

    path_rule {
      paths                      = ["/admin"]
      name                       = "admin-page"
      backend_http_settings_name = "temp-settings"
      backend_address_pool_name  = "empty"
      rewrite_rule_set_name      = "rws-ppl-uatweb-ag-01"
    }
  }
  /* END OF TEMP RULE */
  //////// END OF ROUTING RULES ////////

  //////// REWRITES ////////
  rewrite_rule_set {
    name = "rws-ppl-uatweb-ag-01"

    rewrite_rule {
      name          = "ppl-uat-rewrite-01"
      rule_sequence = 100

      condition {
        variable    = "http_resp_Set-Cookie"
        pattern     = "(.*ApplicationGatewayAffinity=.*)"
        ignore_case = true
      }
      response_header_configuration {
        header_name  = "Set-Cookie"
        header_value = "{http_resp_Set-Cookie_1}; HttpOnly; Secure"
      }
    }

    rewrite_rule {
      name          = "ppl-uat-rewrite-02"
      rule_sequence = 101

      condition {
        variable    = "http_resp_Set-Cookie"
        pattern     = "(.*ApplicationGatewayAffinity=.*)"
        ignore_case = false
      }
      response_header_configuration {
        header_name  = "Set-Cookie"
        header_value = "{http_resp_Set-Cookie_1}; HttpOnly; Secure"
      }
    }
  }
  //////// END OF REWRITES ////////

  //////// HEALTH PROBES ////////
  probe {
    name                                      = "admin-probe"
    protocol                                  = "Http"
    path                                      = "/admin"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    minimum_servers                           = 0
    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

  probe {
    name                                      = "sendapi-probe"
    protocol                                  = "Http"
    path                                      = "/sendapi"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    minimum_servers                           = 0

    match {
      status_code = ["200-499"]
      body        = ""
    }
  }

  probe {
    name                                      = "as4-probe"
    protocol                                  = "Http"
    path                                      = "/as4"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    minimum_servers                           = 0

    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

    //////// END OF HEALTH PROBES ////////
}
