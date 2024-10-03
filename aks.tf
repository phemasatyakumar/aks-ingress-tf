resource "azurerm_kubernetes_cluster" "main_aks" {
  name                      = local.aks_name
  location                  = azurerm_resource_group.rg_tf.location
  resource_group_name       = azurerm_resource_group.rg_tf.name
  dns_prefix                = "aksprod"
  sku_tier                  = "Standard"
  kubernetes_version        = "1.29.0"
  automatic_upgrade_channel = "stable"
  node_resource_group       = "${local.rg_name}-nodepool-rg"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                 = "default"
    node_count           = 1
    min_count            = 1
    max_count            = 5
    vm_size              = "Standard_D2pds_v5"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    auto_scaling_enabled = true
    type                 = "VirtualMachineScaleSets"

    node_labels = {
      role = "main"
    }

    only_critical_addons_enabled = true     ## By default, AKS prevents app pods on default_node_pool but it is still possible. Hence this field is required to enforce app pods not getting into default_node_pool
    temporary_name_for_rotation="tempnodes" ## This is required for any future changes to default_node_pool
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_aid.id]
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  depends_on = [
    azurerm_role_assignment.network_contributor
  ]

  tags = {
    Environment = local.environment
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  name                  = "main"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main_aks.id
  vm_size               = "Standard_D2pds_v5"
  node_count            = 1
  min_count             = 1
  max_count             = 5
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
  orchestrator_version  = azurerm_kubernetes_cluster.main_aks.kubernetes_version

  auto_scaling_enabled = true

  node_labels = {
    role = "worker01"
  }

  tags = {
    Environment = local.environment
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "azurerm_container_registry" "main_acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.rg_tf.name
  location            = azurerm_resource_group.rg_tf.location
  sku                 = "Standard"
}

resource "azurerm_role_assignment" "acr_role" {
  principal_id                     = azurerm_kubernetes_cluster.main_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main_acr.id
  skip_service_principal_aad_check = true
}

resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${local.rg_name} --name ${local.aks_name} --overwrite-existing"
  }
  depends_on = [azurerm_kubernetes_cluster.main_aks]
}