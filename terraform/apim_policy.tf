resource "azurerm_api_management_api" "chat_api" {
  name                = "chat-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Chatbot API"
  path                = "api/v1/chat"
  protocols           = ["https"]

  service_url = "https://${azurerm_linux_web_app.app.default_hostname}"
}

resource "azurerm_api_management_api_policy" "chat_api_policy" {
  api_name            = azurerm_api_management_api.chat_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <!-- 1. Validate Entra ID JWT Token -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-message="Unauthorized. Token invalid or expired.">
            <openid-config url="https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration" />
            <audiences>
                <audience>api://${var.apim_client_id}</audience>
            </audiences>
            <issuers>
                <issuer>https://login.microsoftonline.com/${var.tenant_id}/v2.0</issuer>
            </issuers>
        </validate-jwt>

        <!-- 2. Strip Authorization Header (Terminate JWT at APIM) -->
        <remove-header name="Authorization" />

        <!-- 3. Inject Gateway Secret & Forward User Context Headers to FastAPI -->
        <set-header name="X-Apim-Gateway-Key" exists-action="override">
            <value>${var.apim_shared_secret}</value>
        </set-header>
        <set-header name="X-User-Id" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Authorization","").Split(' ')[1].AsJwt()?.Claims.GetValueOrDefault("oid", ""))</value>
        </set-header>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}
