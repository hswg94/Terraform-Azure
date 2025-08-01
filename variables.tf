#### Project Configuration ####
# Hostname Configuration for Application Gateway #
variable "app_hostname" {
  description = "Application hostname for listeners and redirects"
  type        = string
  default     = "test123-ap-uat.anacle.com"
}

variable "project_name" {
  description = "Project Codename (e.g., ppl, gwc, cdl, etc)"
  type        = string
  default     = "williamtest"
}

variable "environment" {
  description = "Environment (uat, prd)"
  type        = string
  default     = "uat"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "Southeast Asia"
}

#### Network Configuration ####
# Vnet Configuration #
variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.18.0.0/24"]
}

# Subnet Configuration #
variable "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  type = object({
    agw_subnet = string
    app_subnet = string
    db_subnet  = string
    jh_subnet  = string
  })
  default = {
    agw_subnet = "10.18.0.0/28"
    app_subnet = "10.18.0.16/28"
    db_subnet  = "10.18.0.48/28"
    jh_subnet  = "10.18.0.224/28"
  }
}

# DNS Configuration #
variable "dns_servers" {
  description = "DNS servers for the VNet"
  type        = list(string)
  default     = ["172.18.17.68", "172.18.17.69"]
}

#### Jumphost and Bastion Configuration ####
# Jumphost IP (for NSG rules - with CIDR notation) #
variable "jumphost_ip" {
  description = "Jumphost IP address with CIDR for NSG rules"
  type        = string
  default     = "10.18.0.228/32"
}

# Jumphost Private IP (actual IP without CIDR) #
variable "jumphost_private_ip" {
  description = "Jumphost private IP address"
  type        = string
  default     = "10.18.0.228"
}

# Bastion subnet CIDR #
variable "bastion_subnet_cidr" {
  description = "Bastion subnet CIDR"
  type        = string
  default     = "10.18.0.0/26"
}

#### SSL Certificate Configuration ####
variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = "test-certificate-123"
}

#### SSL Certificate Configuration ####
variable "ssl_certificate_password" {
  description = "Password for the SSL certificate PFX file"
  type        = string
  default     = "Password123!"
  sensitive   = true
}

#### Virtual Machine Configuration ####
variable "vm_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""  # Will be set via tfvars or file function in locals
}

# VM1 Private IP #
variable "vm1_private_ip" {
  description = "Private IP address for VM1"
  type        = string
  default     = "10.18.0.20"
}

# VM2 Private IP #
variable "vm2_private_ip" {
  description = "Private IP address for VM2"
  type        = string
  default     = "10.18.0.21"
}