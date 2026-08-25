# Create 3 private DNS zone for KeyVault,SQL, and webapp

resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = local.private_dns_zones
  name                = each.value.name
  resource_group_name = azurerm_resource_group.webapp-rg.name

  tags = local.common_tags
}

# Create a virtual network link for each private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_vnet_link" {
  for_each            = local.private_dns_zones
  name                = "${each.key}-vnet-link-${local.name_prefix}"
  private_dns_zone_id = azurerm_private_dns_zone.private_dns_zone[each.key].id
  virtual_network_id  = azurerm_virtual_network.webapp-vnet.id

}