resource "azurerm_user_assigned_identity" "user_aid" {
  name                = "aks-identity"
  resource_group_name = azurerm_resource_group.rg_tf.name
  location            = azurerm_resource_group.rg_tf.location
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.rg_tf.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.user_aid.principal_id
}