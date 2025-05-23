/*
Terraform configuration to create an Azure Resource Group with a Hub-and-Spoke network topology.
Includes:
- Resource Group
- Hub Virtual Network
- One or more Spoke Virtual Networks
- VNet Peerings (Hub ↔ Spokes)
- Subnets for each VNet
*/

// variables.tf

// main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

// Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

// Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet.name
  address_space       = var.hub_vnet.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "subnet-hub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_vnet.subnet_prefix]
}

// Spoke Virtual Networks
resource "azurerm_virtual_network" "spoke" {
  for_each            = { for s in var.spokes : s.name => s }
  name                = each.value.name
  address_space       = each.value.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_subnet" {
  for_each = { for s in var.spokes : s.name => s }

  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke[each.key].name
  address_prefixes     = [each.value.subnet_prefix]
}

// Peering: Hub -> Spokes
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = azurerm_virtual_network.spoke

  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = each.value.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  allow_virtual_network_access = true
}

// Peering: Spokes -> Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = azurerm_virtual_network.spoke

  name                      = "peer-${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  allow_virtual_network_access = true
}

// outputs.tf
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




//deploy firewall to hub vnet
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "hub-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

}

  # Allow SSH (port 22) from a trusted IP
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"    # your trusted IP
  destination_address_prefix  = "*"
  
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.hub_nsg.name
}

# Deny SSH (port 22) from anywhere else
resource "azurerm_network_security_rule" "deny_ssh" {
  name                        = "DenySSH"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.hub_nsg.name
}
  

// attach nsg assocciation
resource "azurerm_subnet_network_security_group_association" "hub_nsg_assoc" {
  subnet_id = azurerm_subnet.hub_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
  }

// attach nsg assocciation to spoke vnets
  resource "azurerm_subnet_network_security_group_association" "hub_nsg_assoc_2" {
    for_each = azurerm_subnet.spoke_subnet
  subnet_id = azurerm_subnet.spoke_subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
  }


  // attach NAT gateway to hub vnet
  resource "azurerm_nat_gateway" "hub_nat" {
    name                = "hub-nat"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name            = "Standard"

    }
    resource "azurerm_public_ip" "hub_nat_pip" {
      name                = "hub-nat-pip"
      resource_group_name = azurerm_resource_group.rg.name
      location            = azurerm_resource_group.rg.location
      allocation_method = "Static"
      sku = "Standard"
      }
      resource "azurerm_subnet_nat_gateway_association" "hub_nat_assoc" {
        subnet_id = azurerm_subnet.hub_subnet.id
        nat_gateway_id = azurerm_nat_gateway.hub_nat.id
        }
        # resource "azurerm_subnet_nat_gateway_association" "hub_nat_assoc_2" {
        #   for_each = azurerm_subnet.spoke_subnet
        #   subnet_id = azurerm_subnet.spoke_subnet[each.key].id
        #   nat_gateway_id = azurerm_nat_gateway.hub_nat.id
        #   }

        // attach public ip to NAT gateway
        resource "azurerm_nat_gateway_public_ip_association" "hub_nat_IP_assoc" {
          nat_gateway_id = azurerm_nat_gateway.hub_nat.id
          public_ip_address_id = azurerm_public_ip.hub_nat_pip.id
          }

    
// create a linux vm and attach to the hub vnet

resource "azurerm_network_interface" "main" {
  name                = "vm_nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "hub_subnet"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "linuxvm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_F2s_v2"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadOnly"

    diff_disk_settings {
      option = "Local"
    }
  }
}






        
                



