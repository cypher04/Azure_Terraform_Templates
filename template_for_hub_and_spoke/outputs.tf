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

//output all the public IP addresses of the Linux VMs in each spoke

output "spoke_vm_public_ips" {
  description = "Public IP addresses of the Linux VMs in each spoke"
  value = {
    for k, pip in azurerm_public_ip.spoke_vm_pip : k => pip.ip_address
  }
}

// output nat gateway public IP address 
output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway in the hub"
  value       = azurerm_public_ip.hub_nat_pip.ip_address
}

output "spoke_vm_private_ips" {
  description = "Private IP addresses of the Linux VMs in each spoke"
  value = {
    for k, nic in azurerm_network_interface.spoke_vm_nic : k => nic.private_ip_address
  }
}

output "firewall_pip" {
  description = "Public IP address of the Azure Firewall"
  value       = azurerm_public_ip.firewall_pip.ip_address 
  
}

output "hub_vnet_subnet_id" {
  description = "ID of the hub VNet subnet"
  value       = azurerm_subnet.hub_subnet.id
  
}



