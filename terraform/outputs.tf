output "apim_gateway_url" {
  description = "The URL of the API Management Gateway"
  value       = azurerm_api_management.apim.gateway_url
}

output "web_app_hostname" {
  description = "The hostname of the FastAPI Web App"
  value       = azurerm_linux_web_app.app.default_hostname
}

output "cosmos_db_endpoint" {
  description = "The endpoint URL for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}

output "web_pubsub_hostname" {
  description = "The hostname of the Web PubSub instance"
  value       = azurerm_web_pubsub.pubsub.hostname
}
