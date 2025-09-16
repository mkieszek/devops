# Terraform Configuration Example
# This example demonstrates best practices for Azure resource deployment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Configure remote state storage
  backend "azurerm" {
    # Configuration should be provided via backend config file
    # or environment variables for security
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
}

# Local values for common configurations
locals {
  common_tags = {
    Environment   = var.environment
    Project      = "DevOps-Tools"
    ManagedBy    = "Terraform"
    Owner        = var.owner
    CostCenter   = var.cost_center
  }
  
  # Resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# Storage Account for general purpose
resource "azurerm_storage_account" "main" {
  name                     = "${replace(local.resource_prefix, "-", "")}sa"
  resource_group_name      = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  
  # Security settings
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  tags = local.common_tags
}

# Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                = "${local.resource_prefix}-kv"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = var.key_vault_sku
  
  # Security settings
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  
  tags = local.common_tags
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Key Vault access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore"
  ]
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.resource_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  
  tags = local.common_tags
}