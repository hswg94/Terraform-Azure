# Key Vault for SSL Certificate Management (Azure's equivalent to AWS ACM)
resource "azurerm_key_vault" "ssl-certificates" {
  name                = "kv-${var.project_name}-${var.environment}-ssl"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Soft delete and purge protection settings
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Enable for deployment to Application Gateway
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true

  # Access policy for the current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update",
      "Recover",
      "Purge",
      "ManageContacts",
      "ManageIssuers",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Purge",
    ]
  }

  # Access policy for Application Gateway Managed Identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.agw-identity.principal_id

    certificate_permissions = [
      "Get",
      "List",
    ]

    secret_permissions = [
      "Get",
      "List",
    ]
  }

  tags = {
    Environment = var.environment
    Purpose     = "SSL Certificate Management"
  }
}

# Managed Identity for Application Gateway to access Key Vault
resource "azurerm_user_assigned_identity" "agw-identity" {
  name                = "mi-${var.project_name}-${var.environment}-agw"
  location            = azurerm_resource_group.newproj-rg.location
  resource_group_name = azurerm_resource_group.newproj-rg.name
}

# Self-signed certificate in Key Vault (for testing)
resource "azurerm_key_vault_certificate" "ssl-certificate" {
  name         = var.ssl_certificate_name
  key_vault_id = azurerm_key_vault.ssl-certificates.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Customize subject for your domain
      subject = "CN=${var.app_hostname}"

      # Add Subject Alternative Names
      subject_alternative_names {
        dns_names = [
          var.app_hostname,
        ]
      }

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      validity_in_months = 12
    }
  }

  depends_on = [azurerm_key_vault.ssl-certificates]
}

# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Output Key Vault information
output "key_vault_name" {
  value = azurerm_key_vault.ssl-certificates.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.ssl-certificates.vault_uri
}

output "certificate_secret_id" {
  value = azurerm_key_vault_certificate.ssl-certificate.secret_id
}
