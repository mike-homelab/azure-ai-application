# Autoscale setting commented out for F1 Free Tier App Service Plan compatibility
# resource "azurerm_monitor_autoscale_setting" "app_autoscale" {
#   name                = "autoscale-chat-app-${var.unique_suffix}"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   location            = data.azurerm_resource_group.rg.location
#   target_resource_id  = azurerm_service_plan.asp.id
# 
#   profile {
#     name = "defaultProfile"
# 
#     capacity {
#       default = 1
#       minimum = 1
#       maximum = 3
#     }
# 
#     rule {
#       metric_trigger {
#         metric_name        = "ActiveMessages"
#         metric_resource_id = azurerm_servicebus_namespace.sb.id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "GreaterThan"
#         threshold          = 10
#       }
# 
#       scale_action {
#         direction = "Increase"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT5M"
#       }
#     }
# 
#     rule {
#       metric_trigger {
#         metric_name        = "ActiveMessages"
#         metric_resource_id = azurerm_servicebus_namespace.sb.id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT10M"
#         time_aggregation   = "Average"
#         operator           = "LessThanOrEqual"
#         threshold          = 2
#       }
# 
#       scale_action {
#         direction = "Decrease"
#         type      = "ChangeCount"
#         value     = "1"
#         cooldown  = "PT10M"
#       }
#     }
#   }
# }
