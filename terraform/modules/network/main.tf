variable "rg_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "aks_subnets" { type = list(string) }

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnets
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-aks"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "aks_subnet_id" { value = azurerm_subnet.aks.id }
