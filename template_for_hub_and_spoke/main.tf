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
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "rg-hub-spoke-demo"
}

variable "hub_vnet" {
  description = "Settings for the hub virtual network"
  type = object({
    name          = string
    address_space = list(string)
    subnet_prefix = string
  })
  default = {
    name          = "vnet-hub"
    address_space = ["10.0.0.0/16"]
    subnet_prefix = "10.0.1.0/24"
  }
}

variable "spokes" {
  description = "List of spoke VNets with name, address_space and subnet_prefix"
  type = list(object({
    name          = string
    address_space = list(string)
    subnet_prefix = string
  }))
  default = [
    { name = "vnet-spoke-1", address_space = ["10.1.0.0/16"], subnet_prefix = "10.1.1.0/24" },
    { name = "vnet-spoke-2", address_space = ["10.2.0.0/16"], subnet_prefix = "10.2.1.0/24" }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = { environment = "demo" }
}


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

