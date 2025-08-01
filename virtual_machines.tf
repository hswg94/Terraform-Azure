# Virtual Machines for Application Gateway Backend Pool

# Local values for SSH key handling
locals {
  ssh_public_key = var.vm_ssh_public_key != "" ? var.vm_ssh_public_key : file("${path.module}/terraform_azure_key.pub")
}

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
  custom_data = base64encode(<<-EOF
#!/bin/bash
apt-get update
apt-get install -y nginx

# Create health endpoints
mkdir -p /var/www/html/admin/health
mkdir -p /var/www/html/api

# Create health check responses
echo "VM1 Health OK" > /var/www/html/health
echo "VM1 Admin Health OK" > /var/www/html/admin/health/index.html

# Create a simple API endpoint
cat > /var/www/html/api/test.html << 'EOL'
{
  "server": "vm1",
  "status": "healthy",
  "timestamp": "$(date -Iseconds)"
}
EOL

# Configure nginx for health endpoints
cat > /etc/nginx/sites-available/default << 'EOL'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        add_header Content-Type text/plain;
        return 200 "VM1 Health OK\n";
    }

    location /admin/health {
        add_header Content-Type text/plain;
        return 200 "VM1 Admin Health OK\n";
    }

    location /api/ {
        add_header Content-Type application/json;
        try_files $uri $uri/ =404;
    }
}
EOL

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Add server identification
echo "<h1>Server: VM1 - $(hostname)</h1>" > /var/www/html/index.html
echo "<p>Application Gateway Backend Server 1</p>" >> /var/www/html/index.html
echo "<p>Health endpoints:</p>" >> /var/www/html/index.html
echo "<ul><li><a href='/health'>/health</a></li><li><a href='/admin/health'>/admin/health</a></li></ul>" >> /var/www/html/index.html
EOF
  )

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
  custom_data = base64encode(<<-EOF
#!/bin/bash
apt-get update
apt-get install -y nginx

# Create health endpoints
mkdir -p /var/www/html/admin/health
mkdir -p /var/www/html/api

# Create health check responses
echo "VM2 Health OK" > /var/www/html/health
echo "VM2 Admin Health OK" > /var/www/html/admin/health/index.html

# Create a simple API endpoint
cat > /var/www/html/api/test.html << 'EOL'
{
  "server": "vm2",
  "status": "healthy",
  "timestamp": "$(date -Iseconds)"
}
EOL

# Configure nginx for health endpoints
cat > /etc/nginx/sites-available/default << 'EOL'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        add_header Content-Type text/plain;
        return 200 "VM2 Health OK\n";
    }

    location /admin/health {
        add_header Content-Type text/plain;
        return 200 "VM2 Admin Health OK\n";
    }

    location /api/ {
        add_header Content-Type application/json;
        try_files $uri $uri/ =404;
    }
}
EOL

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Add server identification
echo "<h1>Server: VM2 - $(hostname)</h1>" > /var/www/html/index.html
echo "<p>Application Gateway Backend Server 2</p>" >> /var/www/html/index.html
echo "<p>Health endpoints:</p>" >> /var/www/html/index.html
echo "<ul><li><a href='/health'>/health</a></li><li><a href='/admin/health'>/admin/health</a></li></ul>" >> /var/www/html/index.html
EOF
  )

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
