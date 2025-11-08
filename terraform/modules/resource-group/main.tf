variable "name" { type = string }
variable "location" { type = string }

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
}

output "name" { value = azurerm_resource_group.this.name }
