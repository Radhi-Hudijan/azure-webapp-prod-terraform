terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate13869"
    container_name       = "tfstate"
    key                  = "webapp/terraform.tfstate"
  }
}