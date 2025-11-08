output "resource_group" { value = module.rg.name }
output "aks_name"       { value = module.aks.name }
output "kubelet_identity_client_id" { value = module.aks.kubelet_identity_client_id }
