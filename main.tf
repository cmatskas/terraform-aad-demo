terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
  }
   backend "azurerm" {
    storage_account_name = "cmterraformbackend"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_azuread_auth     = true
    subscription_id      = "e42acc2d-8462-4fb5-bf0d-d983c0017584"
    tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
 name     = var.resource_group_name
 location = var.location
}

data "azurerm_key_vault" "myKeyVault" {
  name                = "cm-identity-kv"
  resource_group_name = "identity"
}

data "azurerm_key_vault_secret" "admin_username" {
  name = "sqlAdministratorLogin"
  key_vault_id = data.azurerm_key_vault.myKeyVault.id
}

data "azurerm_key_vault_secret" "admin_password" {
  name = "sqlAdministratorLoginPassword"
  key_vault_id = data.azurerm_key_vault.myKeyVault.id
}

resource "azurerm_mssql_server" "cmsqlserver" {
  name                           = "cm-devops-tf-demo-sqlserver"
  resource_group_name            = var.resource_group_name
  location                       = var.location
  version                        = "12.0"
  administrator_login            = data.azurerm_key_vault_secret.admin_username.value
  administrator_login_password   = data.azurerm_key_vault_secret.admin_password.value
  minimum_tls_version            = "1.2"
  
  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id = "2b548a1b-e0ab-49b8-a683-ebd48b4e7142"
  }
}

resource "azurerm_mssql_database" "test2" {
  name           = "dm-devops-tf-demo-db"
  server_id      = azurerm_mssql_server.cmsqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = false
}