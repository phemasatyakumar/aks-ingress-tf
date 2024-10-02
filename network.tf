resource "azurerm_virtual_network" "vn_prod" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg_tf.location
  resource_group_name = azurerm_resource_group.rg_tf.name
  address_space       = ["10.8.0.0/16"]

  tags = {
    environment = local.environment
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg_tf.name
  virtual_network_name = azurerm_virtual_network.vn_prod.name
  address_prefixes     = ["10.8.0.0/24"]
}

resource "azurerm_subnet" "applications_subnet" {
  name                 = "application-subnet"
  resource_group_name  = azurerm_resource_group.rg_tf.name
  virtual_network_name = azurerm_virtual_network.vn_prod.name
  address_prefixes     = ["10.8.8.0/24"]
}