// This is the main Terraform configuration file for the hub-and-spoke network topology.


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
  features {   } # Ensure you have the Azure provider configured
  # subscription_id = "var.subscription_id"
}
resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  address_space       = var.hub_address_space
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
}
resource "azurerm_subnet" "hub" {
  name                 = var.hub_subnet_name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_subnet_prefix
}
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = var.hub_to_spoke_peering_name
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
    allow_gateway_transit        = true
    use_remote_gateways          = false
}
resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  address_space       = var.spoke_address_space   
    location            = azurerm_resource_group.hub.location
    resource_group_name = azurerm_resource_group.hub.name
}
resource "azurerm_subnet" "spoke" {
    name                 = var.spoke_subnet_name
    resource_group_name  = azurerm_resource_group.hub.name
    virtual_network_name = azurerm_virtual_network.spoke.name
    address_prefixes     = var.spoke_subnet_prefix
    }
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
    name                      = var.spoke_to_hub_peering_name
    resource_group_name       = azurerm_resource_group.hub.name
    virtual_network_name      = azurerm_virtual_network.spoke.name
    remote_virtual_network_id = azurerm_virtual_network.hub.id
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    # use_remote_gateways          = true
}

// create NSG group for the hub subnet
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "${var.hub_subnet_name}-nsg"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
} 
resource "azurerm_subnet_network_security_group_association" "hub_nsg_association" {
  subnet_id                 = azurerm_subnet.hub.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
}
// create NSG group for the spoke subnet
resource "azurerm_network_security_group" "spoke_nsg" {
  name                = "${var.spoke_subnet_name}-nsg"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
}
resource "azurerm_subnet_network_security_group_association" "spoke_nsg_association" {
  subnet_id                 = azurerm_subnet.spoke.id
  network_security_group_id = azurerm_network_security_group.spoke_nsg.id
}



