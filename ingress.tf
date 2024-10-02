resource "azurerm_public_ip" "ingress_nginx_pip" {
  name                = "ingress-nginx-pip"
  location            = azurerm_resource_group.rg_tf.location
  resource_group_name = azurerm_resource_group.rg_tf.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = local.environment
  }
}

resource "helm_release" "ingress_nginx" {
  name             = local.nginx_ingress_name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true

  values = [<<EOF
  controller:
      replicaCount: 1
      extraArgs:
        ingress-class: ingress-nginx
      publishService:
        enabled: true
      service:
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
          service.beta.kubernetes.io/azure-load-balancer-resource-group: ${local.rg_name} # The resource group where the public IP is located
        loadBalancerIP: ${azurerm_public_ip.ingress_nginx_pip.ip_address}
      ingressClassResource:
        name: ingress-nginx
      watchIngressWithoutClass: true
    EOF
  ]

  lifecycle {
    ignore_changes = [
      set,
    ]
  }

  depends_on = [null_resource.kubectl, azurerm_public_ip.ingress_nginx_pip]
}