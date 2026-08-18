
# creating a virtual network
resource "azurerm_virtual_network" "webapp-vnet" {
  name                = "vnet-${local.name_prefix}-01"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.webapp-rg.location
  resource_group_name = azurerm_resource_group.webapp-rg.name

  tags = local.common_tags
}


# creating subnets with for each loop
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = "${each.key}-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.webapp-rg.name
  virtual_network_name = azurerm_virtual_network.webapp-vnet.name
  address_prefixes     = [each.value.cidr]

  # dynamically create a delegation block for the app (snet-app) subnet
    dynamic "delegation" {
        for_each = each.value.delegation == true ? [1] : []
        content {
        name = "delegation-${var.project}"
        service_delegation {
            name = "Microsoft.Web/serverFarms"
            actions = [
            "Microsoft.Network/virtualNetworks/subnets/action",
            "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
        }
        }
    }

}

# Creating a network security group for each subnet
resource "azurerm_network_security_group" "nsg" {
    for_each            = var.subnets
    name                = "${each.value.nsg}-${local.name_prefix}"
    location            = azurerm_resource_group.webapp-rg.location
    resource_group_name = azurerm_resource_group.webapp-rg.name

    dynamic "security_rule" {
        
    }


    tags = local.common_tags
}