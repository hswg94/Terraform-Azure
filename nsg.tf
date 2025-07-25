# Network Security Group for Application Subnet
resource "azurerm_network_security_group" "nsg-ppl-apt-app01" {
  name                = "nsg-${var.project_name}-${var.environment}apt-app01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  security_rule {
    name                       = "AllowJumphostInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = var.jumphost_ip
    destination_address_prefix = azurerm_subnet.newproj-app01-subnet.address_prefixes[0]
    destination_port_ranges    = ["3389", "22"]
  }

  security_rule {
    name                       = "AllowAppGWInBound"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = azurerm_subnet.newproj-agw01-subnet.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.newproj-app01-subnet.address_prefixes[0]
    destination_port_ranges    = ["80", "443", "8080"]
  }

  security_rule {
    name                       = "DenyAnyInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for Database Subnet
resource "azurerm_network_security_group" "nsg-ppl-dbt-dbs01" {
  name                = "nsg-${var.project_name}-${var.environment}dbt-dbs01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  security_rule {
    name                       = "AllowAppSQLInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = azurerm_subnet.newproj-app01-subnet.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.newproj-db-subnet.address_prefixes[0]
    destination_port_range     = "1433"
  }

  security_rule {
    name                       = "DenyAnyInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for Jumphost Subnet
resource "azurerm_network_security_group" "nsg-ppl-mgt-jh01" {
  name                = "nsg-${var.project_name}-${var.environment}mgt-jh01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  security_rule {
    name                       = "AllowBastionInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = var.bastion_subnet_cidr
    destination_address_prefix = var.jumphost_ip
    destination_port_range     = "3389"
  }

  security_rule {
    name                       = "DenyAnyInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for Application Gateway Subnet
resource "azurerm_network_security_group" "nsg-ppl-web-apgw01" {
  name                = "nsg-${var.project_name}-${var.environment}web-apgw01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  security_rule {
    name                       = "AllowHttpHttpsInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.newproj-agw01-subnet.address_prefixes[0]
    destination_port_ranges    = ["80", "443"]
  }

  security_rule {
    name                       = "AllowAzureLBInBound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowGatewayManagerInBound"
    priority                   = 2010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
  }

  security_rule {
    name                       = "DenyAnyInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group Associations
resource "azurerm_subnet_network_security_group_association" "agw-nsg-association" {
  subnet_id                 = azurerm_subnet.newproj-agw01-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-ppl-web-apgw01.id
}

resource "azurerm_subnet_network_security_group_association" "app-nsg-association" {
  subnet_id                 = azurerm_subnet.newproj-app01-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-ppl-apt-app01.id
}

resource "azurerm_subnet_network_security_group_association" "db-nsg-association" {
  subnet_id                 = azurerm_subnet.newproj-db-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-ppl-dbt-dbs01.id
}

resource "azurerm_subnet_network_security_group_association" "jh-nsg-association" {
  subnet_id                 = azurerm_subnet.newproj-jh-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-ppl-mgt-jh01.id
}