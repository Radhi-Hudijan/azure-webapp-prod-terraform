
# # Data source to get the identity Terraform is running as for tanent_id and object_id and access policy for the key vault
data "azurerm_client_config" "current" {}

# create a key vault with the access policy for the current user
resource "azurerm_key_vault" "key_vault" {
  name                          = "key-vault-${local.name_prefix}"
  location                      = azurerm_resource_group.webapp-rg.location
  resource_group_name           = azurerm_resource_group.webapp-rg.name
  rbac_authorization_enabled    = true
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled      = false
  public_network_access_enabled = true

  sku_name = "standard"

  tags = local.common_tags
}

# role assignment for the current user (terraform) to have access to the key vault secrets
resource "azurerm_role_assignment" "kv_secret_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# role assignment for the webapp managed identity to have access to the key vault secrets
resource "azurerm_role_assignment" "kv_secret_role_webapp" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}

resource "random_password" "sql_admin" {
length = 24
special = true
}

# test secret to be created in the key vault
resource "azurerm_key_vault_secret" "test_secret" {
  name         = "secret-db-password"
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_role_assignment.kv_secret_role_webapp]

  tags = local.common_tags
}