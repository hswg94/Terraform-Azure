#### Project Configuration ####
variable "project_name" {
  description = "Project Codename (e.g., ppl, gwc, cdl, etc)"
  type        = string
  default     = "ppl"
}

variable "environment" {
  description = "Environment (uat, prd)"
  type        = string
  default     = "uat"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Southeast Asia"
}

##### Network Configuration #####
# Vnet Configuration #
variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["172.18.132.0/24"]
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
    agw_subnet = "172.18.132.0/28"
    app_subnet = "172.18.132.16/28"
    db_subnet  = "172.18.132.48/28"
    jh_subnet  = "172.18.132.224/28"
  }
}
# DNS Configuration #
variable "dns_servers" {
  description = "DNS servers for the VNet"
  type        = list(string)
  default     = ["172.18.17.68", "172.18.17.69"]
}

#### Jumphost and Bastion Configuration ####
# Jumphost IP #
variable "jumphost_ip" {
  description = "Jumphost IP address"
  type        = string
  default     = "172.18.132.228/32"
}

# Bastion subnet CIDR #
variable "bastion_subnet_cidr" {
  description = "Bastion subnet CIDR"
  type        = string
  default     = "172.18.17.0/26"
}

#### Application Gateway Configuration ####
# Hostname Configuration #
variable "app_hostname" {
  description = "Application hostname for listeners and redirects"
  type        = string
  default     = "invoicenow-ap-uat.anacle.com"
}