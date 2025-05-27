output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "hub_vnet_id" {
  description = "ID of the hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_ids" {
  description = "IDs of the spoke VNets"
  value       = [for s in azurerm_virtual_network.spoke : s.id]
}

output "hub_nat_pip_id" {
  description = "public Ip Address attached to NAT Gateway"
  value       = azurerm_public_ip.hub_nat_pip
}

output "vm_public_ip" {
  description = "Public IP address of the Linux VM"
  value       = azurerm_public_ip.vm_pip.ip_address
  
}
