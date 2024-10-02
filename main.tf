locals {
  location           = "eastus"
  rg_name            = "rg-tf-aks"
  environment        = "development"
  vnet_name          = "aks-vnet"
  aks_name           = "main-aks"
  acr_name           = "laacr"
  nginx_ingress_name = "ingress-nginx"
  cert_manager_name  = "cert-manager"
  dns_name           = "test.com"
}

resource "azurerm_resource_group" "rg_tf" {
  name     = local.rg_name
  location = local.location
}
