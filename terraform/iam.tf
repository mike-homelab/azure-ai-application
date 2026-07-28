# Role Assignments for FastAPI Web App Managed Identity

# 1. Service Bus Data Receiver & Sender
resource "azurerm_role_assignment" "sb_receiver" {
  scope                = azurerm_servicebus_queue.sb_queue.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "sb_sender" {
  scope                = azurerm_servicebus_queue.sb_queue.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

# 2. Cosmos DB Built-in Data Contributor
resource "azurerm_cosmosdb_sql_role_assignment" "cosmos_data_contributor" {
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  # Built-in role ID for "Cosmos DB Built-in Data Contributor"
  role_definition_id = "${azurerm_cosmosdb_account.cosmos.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id       = azurerm_linux_web_app.app.identity[0].principal_id
  scope              = azurerm_cosmosdb_account.cosmos.id
}

# 3. Web PubSub Service Owner
resource "azurerm_role_assignment" "pubsub_owner" {
  scope                = azurerm_web_pubsub.pubsub.id
  role_definition_name = "WebPubSub Service Owner"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

# 4. Cognitive Services OpenAI User & Azure AI Developer
resource "azurerm_role_assignment" "ai_openai_user" {
  scope                = azurerm_cognitive_account.ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "ai_developer" {
  scope                = azurerm_cognitive_account.ai.id
  role_definition_name = "Cognitive Services User" # Closest standard role for general AI Developer access
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}
