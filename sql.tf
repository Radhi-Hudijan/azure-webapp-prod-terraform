# creating an azure sql server
resource "azurerm_mssql_server" "sql-server" {
  name                         = "sql-server-${local.name_prefix}"
  resource_group_name          = azurerm_resource_group.webapp-rg.name
  location                     = azurerm_resource_group.webapp-rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"

  # block public network access to the sql server ,using private endpoint to access the sql server
  public_network_access_enabled = false

  tags = local.common_tags
}


# creating an azure sql database
resource "azurerm_mssql_database" "sql-database" {
  name        = "sqldb-${local.name_prefix}"
  server_id   = azurerm_mssql_server.sql-server.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name    = "S0"

  tags = local.common_tags
}

# creating a private endpoint for the sql server
resource "azurerm_private_endpoint" "sql-private-endpoint" {
  name                = "sql-private-endpoint-${local.name_prefix}"
  location            = azurerm_resource_group.webapp-rg.location
  resource_group_name = azurerm_resource_group.webapp-rg.name
  subnet_id           = azurerm_subnet.subnet["snet-pe"].id
  private_service_connection {
    name                           = "sql-private-service-connection-${local.name_prefix}"
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]

  }

  private_dns_zone_group {
    name                 = "sql-private-dns-zone-group-${local.name_prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone["sql"].id]
  }

  tags = local.common_tags
}

# store the sql connection string in the key vault as a secret
resource "azurerm_key_vault_secret" "sql-connection-string" {
  name         = "sql-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.sql-server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql-database.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${random_password.sql_admin.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_role_assignment.kv_secret_role]

  tags = local.common_tags

}