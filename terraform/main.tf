module "rg" {
  source   = "./modules/resource-group"
  name     = var.rg_name
  location = var.location
}

module "network" {
  source        = "./modules/network"
  rg_name       = module.rg.name
  location      = var.location
  address_space = ["10.30.0.0/16"]
  aks_subnets   = ["10.30.1.0/24"]
}

module "aks" {
  source                     = "./modules/aks"
  rg_name                    = module.rg.name
  location                   = var.location
  cluster_name               = var.cluster_name
  kubernetes_version         = var.k8s_version
  node_count                 = var.node_count
  node_vm_size               = var.node_vm_size
  subnet_id                  = module.network.aks_subnet_id
  network_plugin             = "azure"
  network_policy             = "azure"
  rbac_enabled               = true
  oidc_issuer_enabled        = true
  workload_identity_enabled  = true
  local_account_disabled     = true
}

# Optional ACR for images (attach pull permission to AKS)
resource "azurerm_container_registry" "acr" {
  count               = var.acr_name == null ? 0 : 1
  name                = var.acr_name
  resource_group_name = module.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "aks_pull_acr" {
  count                = var.acr_name == null ? 0 : 1
  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}
