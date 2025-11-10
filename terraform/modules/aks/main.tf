variable "rg_name" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "kubernetes_version" { type = string, default = null }
variable "node_count" { type = number }
variable "node_vm_size" { type = string }
variable "subnet_id" { type = string }
variable "network_plugin" { type = string, default = "azure" }
variable "network_policy" { type = string, default = "azure" }
variable "rbac_enabled" {
  type    = bool
  default = true
}
variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}
variable "workload_identity_enabled" {
  type    = bool
  default = true
}
variable "local_account_disabled" {
  type    = bool
  default = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = var.subnet_id
    only_critical_addons_enabled = false
  }

  identity { type = "SystemAssigned" }

  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled
  local_account_disabled    = var.local_account_disabled

  azure_policy_enabled = true

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }

  role_based_access_control_enabled = var.rbac_enabled

  # Recommended: disable legacy k8s dashboard
  kubernetes_version = var.kubernetes_version
}

output "name" { value = azurerm_kubernetes_cluster.aks.name }
output "kubelet_identity_object_id" { value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id }
output "kubelet_identity_client_id" { value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id }
