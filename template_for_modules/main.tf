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
}

module "hub_and_spoke" {
  source = "./modules/hub_and_spoke"

  # Define variables for the module
  resource_group_name = var.resource_group_name
  location            = var.location
  hub_address_space   = var.hub_address_space
  spoke_address_space = var.spoke_address_space
  hub_subnet_prefix   = var.hub_subnet_prefix
  spoke_subnet_prefix = var.spoke_subnet_prefix
  hub_to_spoke_peering_name = var.hub_to_spoke_peering_name
  spoke_to_hub_peering_name = var.spoke_to_hub_peering_name
  hub_vnet_name       = var.hub_vnet_name
  spoke_vnet_name    = var.spoke_vnet_name
  hub_subnet_name     = var.hub_subnet_name
  spoke_subnet_name  = var.spoke_subnet_name
  # subscription_id = "var.subscription_id"

  # Add any other necessary variables here
}