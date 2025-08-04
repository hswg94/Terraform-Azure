# Virtual Machines for Application Gateway Backend Pool

# VM 1 - Main Application Server
resource "azurerm_network_interface" "vm1-nic" {
  name                = "nic-${var.project_name}-${var.environment}-vm01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.newproj-app01-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm1_private_ip  # Using individual variable
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm-${var.project_name}-${var.environment}-app01"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  # Disable password authentication and use SSH keys
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm1-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = local.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install and configure web server with health endpoints
  custom_data = base64encode(file("${path.module}/custom_data/vm1-setup.sh"))

  tags = {
    Environment = var.environment
    Role        = "backend-server"
    Server      = "vm1"
  }
}

# VM 2 - Secondary Application Server
resource "azurerm_network_interface" "vm2-nic" {
  name                = "nic-${var.project_name}-${var.environment}-vm02"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.newproj-app01-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm2_private_ip  # Using individual variable
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm-${var.project_name}-${var.environment}-app02"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  # Disable password authentication and use SSH keys
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm2-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = local.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install and configure web server with health endpoints
  custom_data = base64encode(file("${path.module}/custom_data/vm2-setup.sh"))

  tags = {
    Environment = var.environment
    Role        = "backend-server"
    Server      = "vm2"
  }
}

# Outputs for VM information
output "vm1_private_ip" {
  value = azurerm_network_interface.vm1-nic.private_ip_address
}

output "vm2_private_ip" {
  value = azurerm_network_interface.vm2-nic.private_ip_address
}

output "vm_ssh_commands" {
  value = {
    vm1 = "ssh azureuser@${azurerm_network_interface.vm1-nic.private_ip_address}"
    vm2 = "ssh azureuser@${azurerm_network_interface.vm2-nic.private_ip_address}"
  }
}
