resource "azurerm_resource_group" "webapp-rg" {
  name     = "rg-${local.name_prefix}-01"
  location = var.location
  tags     = local.common_tags

}