terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "main-aks"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "main-aks"
  }
}