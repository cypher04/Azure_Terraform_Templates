// Variables for the hub-and-spoke network topology
variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "hub_address_space" {
  description = "The address space for the hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  description = "The address space for the spoke virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}   
variable "hub_subnet_name" {
  description = "The name of the hub subnet"
  type        = string
  default     = "HubSubnet"
}
variable "hub_subnet_prefix" {
  description = "The address prefix for the hub subnet"
  type        = string
  default     = ["10.0.0/24"]
}
variable "spoke_subnet_name" {
  description = "The name of the spoke subnet"
  type        = string
  default     = "SpokeSubnet"
}
variable "spoke_subnet_prefix" {
  description = "The address prefix for the spoke subnet"
  type        = string
  default     = ["10.1.0/24"]
}   
variable "hub_vnet_name" {
  description = "The name of the hub virtual network"
  type        = string
  default     = "HubVNet"
}
variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  type        = string
  default     = "SpokeVNet"
}   

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created"
  type        = string
  default     = "HubSpokeResourceGroup"
}

variable "hub_to_spoke_peering_name" {
  description = "The name of the peering from hub to spoke"
  type        = string
  default     = "HubToSpokePeering"     
  
}

variable "spoke_to_hub_peering_name" {
  description = "The name of the peering from spoke to hub"
  type        = string
  default     = "SpokeToHubPeering"
}
