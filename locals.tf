locals {
  name_prefix           = "${var.project}-${var.environment}-${var.location_abbr}"

  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  }

  nsg_rules = {
    agw = [
      {
        name                       = "allow-gatewayManager"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      } ,
      {
        name                       = "allow-internet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = ["80","443"]
        source_address_prefix    = "Internet"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-AzureLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
    ]
    app = []
    pe  = []
  }
}