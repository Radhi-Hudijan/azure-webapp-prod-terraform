resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-${local.name_prefix}"
  location            = azurerm_resource_group.webapp-rg.location
  resource_group_name = azurerm_resource_group.webapp-rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku_name

  tags = local.common_tags
}

# create an app service for the webapp
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-${local.name_prefix}"
  location            = azurerm_resource_group.webapp-rg.location
  resource_group_name = azurerm_resource_group.webapp-rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  https_only          = true
  #   public_network_access_enabled = false
  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      docker_image_name = "nginx:latest"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# add vnet integration to the app service to connect to the vnet
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.subnet["snet-app"].id
}