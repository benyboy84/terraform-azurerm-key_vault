resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "canadacentral"
}

data "azurerm_client_config" "this" {}

module "keyvault" {
  source = "../"

  name                        = "example"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  admin_objects_ids           = [data.azurerm_client_config.this.object_id]
}