terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "databricks-cea"
}

variable "databricks_token" {
  description = "Databricks API token"
  type        = string
  sensitive   = true
}

variable "databricks_base_url" {
  description = "Databricks serving endpoint URL"
  type        = string
  default = "https://dbc-cbf5e91a-cec8.cloud.databricks.com/serving-endpoints/databricks-gpt-5-1-codex-mini/invocationss"
}

variable "databricks_model_name" {
  description = "Databricks model name"
  type        = string
  default     = "databricks-gpt-5-1-codex-mini"
}

variable "system_prompt" {
  description = "System prompt for the bot"
  type        = string
  default     = "You are an AI assistant that uses Databricks models to help Microsoft 365 users."
}

variable "max_tokens" {
  description = "Maximum tokens for responses"
  type        = number
  default     = 1024
}

variable "temperature" {
  description = "Temperature for model responses"
  type        = number
  default     = 0.2
}

# Local variables
locals {
  resource_suffix = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location
  tags     = local.common_tags
}

# Storage Account for Function App
resource "azurerm_storage_account" "function" {
  name                     = lower(replace("st${var.project_name}${var.environment}", "-", ""))
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

resource "azurerm_storage_container" "deployments" {
  name                  = "function-releases"
  storage_account_name  = azurerm_storage_account.function.name
  container_access_type = "private"
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"
  tags                = local.common_tags
}

# App Service Plan (Consumption)
resource "azurerm_service_plan" "main" {
  name                = "asp-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan
  tags                = local.common_tags
}

# Azure AD App Registration for Bot
resource "azuread_application" "bot" {
  display_name = "${var.project_name}-bot-${var.environment}"
  owners       = [data.azuread_client_config.current.object_id]
  
  # Single tenant configuration
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_application_password" "bot" {
  application_id = azuread_application.bot.id
  display_name   = "Bot Password"
}

resource "azuread_service_principal" "bot" {
  client_id = azuread_application.bot.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

data "azuread_client_config" "current" {}

# Function App
resource "azurerm_linux_function_app" "main" {
  name                       = "func-${local.resource_suffix}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }

    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.main.connection_string

    cors {
      allowed_origins = ["https://portal.azure.com"]
    }

    # Enable remote build
    ftps_state = "FtpsOnly"
  }

  app_settings = {
    # Bot Framework Settings
    MicrosoftAppId         = azuread_application.bot.client_id
    MicrosoftAppType       = "SingleTenant"
    MicrosoftAppTenantId   = data.azuread_client_config.current.tenant_id
    MicrosoftAppPassword   = azuread_application_password.bot.value
    BYPASS_AUTHENTICATION  = "false"

    # Databricks Settings
    DATABRICKS_TOKEN      = var.databricks_token
    DATABRICKS_BASE_URL   = var.databricks_base_url
    DATABRICKS_MODEL_NAME = var.databricks_model_name

    # Model Parameters
    SYSTEM_PROMPT      = var.system_prompt
    OPENAI_MAX_TOKENS  = var.max_tokens
    OPENAI_TEMPERATURE = var.temperature

    # Function App Settings
    FUNCTIONS_WORKER_RUNTIME              = "python"
    AzureWebJobsFeatureFlags              = "EnableWorkerIndexing"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.main.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
    
    # Build settings
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    ENABLE_ORYX_BUILD              = "true"
    
    # Python build settings
    POST_BUILD_COMMAND = "echo 'Build complete'"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

# Bot Service
resource "azurerm_bot_service_azure_bot" "main" {
  name                = "bot-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  microsoft_app_id    = azuread_application.bot.client_id
  sku                 = "F0" # Free tier
  
  # Use SingleTenant instead of deprecated MultiTenant
  microsoft_app_type        = "SingleTenant"
  microsoft_app_tenant_id   = data.azuread_client_config.current.tenant_id

  endpoint = "https://${azurerm_linux_function_app.main.default_hostname}/api/messages"

  tags = local.common_tags

  depends_on = [
    azurerm_linux_function_app.main,
    azuread_service_principal.bot
  ]
}

# Bot Channel - Microsoft Teams
resource "azurerm_bot_channel_ms_teams" "main" {
  bot_name            = azurerm_bot_service_azure_bot.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_bot_service_azure_bot.main.location
}

# Key Vault for Secrets (Optional but recommended)
resource "azurerm_key_vault" "main" {
  name                       = lower(replace("kv-${var.project_name}-${var.environment}", "-", ""))
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azuread_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azuread_client_config.current.tenant_id
    object_id = azurerm_linux_function_app.main.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  # Access policy for current user (for initial setup)
  access_policy {
    tenant_id = data.azuread_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  tags = local.common_tags
}

# Store sensitive values in Key Vault
resource "azurerm_key_vault_secret" "databricks_token" {
  name         = "databricks-token"
  value        = var.databricks_token
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "bot_password" {
  name         = "bot-password"
  value        = azuread_application_password.bot.value
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Outputs
output "function_app_name" {
  value       = azurerm_linux_function_app.main.name
  description = "Name of the Function App"
}

output "function_app_hostname" {
  value       = azurerm_linux_function_app.main.default_hostname
  description = "Hostname of the Function App"
}

output "function_app_id" {
  value       = azurerm_linux_function_app.main.id
  description = "Resource ID of the Function App"
}

output "bot_app_id" {
  value       = azuread_application.bot.client_id
  description = "Microsoft App ID for the bot"
}

output "bot_app_password" {
  value       = azuread_application_password.bot.value
  sensitive   = true
  description = "Microsoft App Password for the bot"
}

output "bot_endpoint" {
  value       = "https://${azurerm_linux_function_app.main.default_hostname}/api/messages"
  description = "Bot messaging endpoint"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the resource group"
}

output "application_insights_key" {
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
  description = "Application Insights instrumentation key"
}

output "application_insights_connection_string" {
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
  description = "Application Insights connection string"
}

output "key_vault_name" {
  value       = azurerm_key_vault.main.name
  description = "Name of the Key Vault"
}

output "storage_account_name" {
  value       = azurerm_storage_account.function.name
  description = "Name of the storage account"
}

output "deployment_command" {
  value = <<-EOT
    # Deploy your Python code with:
    cd src
    zip -r ../function.zip .
    az functionapp deployment source config-zip \
      --resource-group ${azurerm_resource_group.main.name} \
      --name ${azurerm_linux_function_app.main.name} \
      --src ../function.zip
  EOT
  description = "Command to deploy your Python code"
}