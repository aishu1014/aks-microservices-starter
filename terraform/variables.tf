variable "location" { type = string, default = "eastus" }
variable "rg_name"  { type = string, default = "rg-aks-demo" }
variable "cluster_name" { type = string, default = "aks-demo" }
variable "k8s_version"  { type = string, default = null }
variable "node_count"   { type = number, default = 2 }
variable "node_vm_size" { type = string, default = "Standard_DS3_v2" }

# Terraform backend vars
variable "tf_state_rg"        { type = string }
variable "tf_state_sa"        { type = string }
variable "tf_state_container" { type = string }

# Optional: ACR name (must be globally unique)
variable "acr_name" { type = string, default = null }
