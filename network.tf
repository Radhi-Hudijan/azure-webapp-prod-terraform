
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
  name                = "nsg-${each.value.nsg}-${local.name_prefix}"
  location            = azurerm_resource_group.webapp-rg.location
  resource_group_name = azurerm_resource_group.webapp-rg.name

  dynamic "security_rule" {
    for_each = local.nsg_rules[each.value.nsg] # to map the nsg_rules to the subnets, we use the nsg value from the subnets variable to get the corresponding rules from the local.nsg_rules map
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }

  }

  tags = local.common_tags
}

# associating the network security group to the subnet 
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}