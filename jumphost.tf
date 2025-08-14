# Jumphost VM for SSH access to private VMs

# Local values for SSH key handling
locals {
  ssh_public_key = var.vm_ssh_public_key != "" ? var.vm_ssh_public_key : file("${path.module}/terraform_azure_key.pub")
}

resource "azurerm_public_ip" "jumphost-pip" {
  name                = "pip-${var.project_name}-${var.environment}-jumphost"
  resource_group_name = azurerm_resource_group.newproj-rg.name
  location            = azurerm_resource_group.newproj-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_network_interface" "jumphost-nic" {
  name                = "nic-${var.project_name}-${var.environment}-jumphost"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.newproj-jh-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.18.0.228"
    public_ip_address_id          = azurerm_public_ip.jumphost-pip.id
  }
}

resource "azurerm_linux_virtual_machine" "jumphost" {
  name                = "vm-${var.project_name}-${var.environment}-jumphost"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.jumphost-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = local.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install SSH client and tools
  custom_data = base64encode(file("${path.module}/custom_data/jh-setup.sh"))

  tags = {
    Environment = var.environment
    Role        = "jumphost"
  }
}

output "jumphost_public_ip" {
  value = azurerm_public_ip.jumphost-pip.ip_address
}

output "jumphost_ssh_command" {
  value = "ssh -i terraform_azure_key azureuser@${azurerm_public_ip.jumphost-pip.ip_address}"
}
