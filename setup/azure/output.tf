output "subnet_id" {
  value = azurerm_subnet.internal.id
}

output "network_interface_id" {
  value = azurerm_network_interface.dojo.id
}