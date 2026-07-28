# Data source for current subscription
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Service Bus
resource "azurerm_servicebus_namespace" "sb" {
  name                = "sb-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "sb_queue" {
  name         = "chat-queue"
  namespace_id = azurerm_servicebus_namespace.sb.id
}

# Azure Cosmos DB (Free Tier)
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "cosmos-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  free_tier_enabled = true

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cosmos_sqldb" {
  name                = "chat_database"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "cosmos_container" {
  name                  = "chat_history"
  resource_group_name   = azurerm_resource_group.rg.name
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.cosmos_sqldb.name
  partition_key_path    = "/session_id"
  partition_key_version = 1
}

# Azure Web PubSub (Free Tier)
resource "azurerm_web_pubsub" "pubsub" {
  name                = "pubsub-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku      = "Free_F1"
  capacity = 1
}

# Azure AI Foundry / Cognitive Services
resource "azurerm_cognitive_account" "ai" {
  name                = "ai-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}

# Azure App Service Plan & Web App
resource "azurerm_service_plan" "asp" {
  name                = "asp-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "SERVICE_BUS_FQDN"    = "${azurerm_servicebus_namespace.sb.name}.servicebus.windows.net"
    "COSMOS_DB_ENDPOINT"  = azurerm_cosmosdb_account.cosmos.endpoint
    "PUB_SUB_ENDPOINT"    = "https://${azurerm_web_pubsub.pubsub.hostname}"
    "AI_FOUNDRY_ENDPOINT" = azurerm_cognitive_account.ai.endpoint
    "GATEWAY_SECRET"      = var.apim_shared_secret
  }
}

# Azure API Management
resource "azurerm_api_management" "apim" {
  name                = "apim-chat-${var.unique_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email

  sku_name = "Consumption_0"
}
