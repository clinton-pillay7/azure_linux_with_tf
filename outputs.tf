output "resource_group_name" {
  value = azurerm_resource_group.linux-rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.linux-vm.public_ip_address
}

