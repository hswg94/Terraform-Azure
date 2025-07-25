# Azure Web Application Infrastructure Template

A simple Terraform template for Azure web application infrastructure.

## What it creates:
- Virtual Network with 4 subnets
- Application Gateway with WAF
- Network Security Groups  
- Container Registry
- NAT Gateway
- Managed Identity

## Quick Start:

1. **Copy and customize variables:**
   ```bash
   cp dev.tfvars.example my-app.tfvars
   # Edit my-app.tfvars with your values
   ```

2. **Deploy:**
   ```bash
   terraform init
   terraform plan -var-file="my-app.tfvars"
   terraform apply -var-file="my-app.tfvars"
   ```

## Customize for your project:

Edit the `.tfvars` file:
```hcl
project_name = "myapp"        # Your app name
environment  = "prod"         # dev/uat/prod  
location     = "East US"      # Azure region

# Network settings
vnet_address_space = ["10.0.0.0/16"]
subnet_cidrs = {
  agw_subnet = "10.0.1.0/24"  # Application Gateway
  app_subnet = "10.0.2.0/24"  # Application servers
  db_subnet  = "10.0.3.0/24"  # Database/private
  jh_subnet  = "10.0.4.0/24"  # Jumphost/management
}
jumphost_ip = "10.0.4.10/32"  # Specific jumphost IP
```

## Resource naming:
- Resource Group: `rg-{project}-{env}`  
- VNet: `vnet-{env}-{project}`
- Subnets: `sub-{project}-{env}{tier}-{component}01`

That's it! �
