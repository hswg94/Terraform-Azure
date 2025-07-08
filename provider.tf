terraform {
  // when upgrading version, first run 'choco upgrade terraform' on OS.
  required_version = ">= 1.11.4"
  cloud {
    organization = "azure-project-org"
    workspaces {
      name = "azure-project-workspace"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.35.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

/*
Version Constraint Operators:

= or no operator Allows only the exact version specified.
  - Example: = 1.2.3 allows only version 1.2.3

!= Excludes a specific version.
  - Example: != 1.2.3 allows all versions except 1.2.3

>  Allows versions newer than the one specified.
  - Example: > 1.2.3 allows 1.2.4, 1.3.0, 2.0.0, etc.

>= Allows the specified version or newer.
  - Example: >= 1.2.3 allows 1.2.3, 1.2.4, 1.3.0, etc.

<  Allows only versions older than the one specified.
  - Example: < 2.0.0 allows 1.9.9 and below

<= Allows the specified version or older.
  - Example: <= 1.2.3 allows 1.2.3, 1.2.2, etc.

~> Allows only the right-most version component to increment.
  - Example: ~> 1.0.4 allows versions >= 1.0.4 and < 1.1.0
  - Example: ~> 1.1 allows versions >= 1.1.0 and < 2.0.0
*/
