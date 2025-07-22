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
  name                = "testproject-agw-pip"
  resource_group_name = azurerm_resource_group.testproject-rg.name
  location            = azurerm_resource_group.testproject-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_application_gateway" "testproject-agw" {
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.testproject-agw-subnet.id
  }

  name                = "testproject-agw"
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

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  backend_address_pool {
    name = "simplicity-app"
  }

  //// BACKEND SETTINGS ////
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
    name                  = "sendapi-backend-settings"
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

  ////////////////////////////

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.testproject-agw-pip.id
  }

  ////////////////////// FRONTEND PORTS //////////////////////
  frontend_port {
    name = "appGwPublicFrontendPort80"
    port = 80
  }

  frontend_port {
    name = "appGwPublicFrontendPort443"
    port = 443
  }

  frontend_port {
    name = "appGwPublicFrontendPort8008"
    port = 8008
  }
  /////////////////////////////////////////////////////////

  ////////////////////// SSL CERTIFICATES //////////////////////
  ssl_certificate {
    name     = "wildcard-anacle-com-2024-25"
    data     = filebase64("path/to/your/certificate.pfx") # Update this path
    password = "your_certificate_password"                # Update this password
  }
  //////////////////////////////////////////////////////////////

  ////////////////////// LISTENERS //////////////////////
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Http"
    frontend_port_name             = "appGwPublicFrontendPort80"
    host_name                      = "invoicenow-ap-uat.anacle.com"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Https"
    frontend_port_name             = "appGwPublicFrontendPort443"
    host_name                      = "invoicenow-ap-uat.anacle.com"
    ssl_certificate_name           = "wildcard-anacle-com-2024-25"
    require_sni                    = true
  }

  http_listener {
    name                           = "temp-listener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    protocol                       = "Http"
    frontend_port_name             = "appGwPublicFrontendPort8008"
  }

  ///////////////////////////////////////////////////////

  ////////////////////// ROUTING RULES //////////////////////
  ////// HTTP-RULE //////
  request_routing_rule {
    name                        = "http-rule"
    priority                    = 10
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https-redirect"
  }

  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  /////// HTTPS-RULE ///////
  request_routing_rule {
    name               = "https-rule"
    priority           = 100
    http_listener_name = "https-listener"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "https-path-map"
  }

  url_path_map {
    name = "https-path-map"

    path_rule {
      paths                      = ["/sendapi/*"]
      name                       = "sendapi"
      backend_http_settings_name = "sendapi-backend-settings"
      backend_address_pool_name  = "simplicity-app"
    }

    path_rule {
      paths                      = ["/admin/*"]
      name                       = "admin"
      backend_http_settings_name = "admin-backendsettings"
      backend_address_pool_name  = "simplicity-app"
    }

    path_rule {
      paths                      = ["/as4*"]
      name                       = "oxalis"
      backend_http_settings_name = "as4-backendsettings"
      backend_address_pool_name  = "simplicity-app"
    }

    path_rule {
      paths                       = ["/as4/"]
      name                        = "redirect-as4"
      redirect_configuration_name = "external-site-redirect"
    }

    path_rule {
      paths                       = ["/as4/status*"]
      name                        = "as4-redirect-rule"
      redirect_configuration_name = "as4-redirect"
    }
  }

  redirect_configuration {
    name                 = "redirect-as4"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = false
    include_query_string = false
  }

  redirect_configuration {
    name                 = "redirect-as4-status"
    redirect_type        = "Permanent"
    target_url           = "https://invoicenow-ap-uat.anacle.com/as4"
    include_path         = false
    include_query_string = false
  }

  ///////////////////// END OF HTTPS RULE ///////////////////
  ///////////////////////////////////////////////////////////
  ////////////////////// URL PATH MAPS //////////////////////
  ///////////////////////////////////////////////////////////
}
