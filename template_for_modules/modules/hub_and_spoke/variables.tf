// Variables for the hub-and-spoke network topology
variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
 
}

variable "hub_address_space" {
  description = "The address space for the hub virtual network"
  type        = list(string)
 
}

variable "spoke_address_space" {
  description = "The address space for the spoke virtual network"
  type        = list(string)
 
}   
variable "hub_subnet_name" {
  description = "The name of the hub subnet"
  type        = string

}
variable "hub_subnet_prefix" {
  description = "The address prefix for the hub subnet"
  type        = list(string)
 
}
variable "spoke_subnet_name" {
  description = "The name of the spoke subnet"
  type        = string

}
variable "spoke_subnet_prefix" {
  description = "The address prefix for the spoke subnet"
  type        = list(string)

}   
variable "hub_vnet_name" {
  description = "The name of the hub virtual network"
  type        = string

}
variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  type        = string

}   

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created"
  type        = string

}

variable "hub_to_spoke_peering_name" {
  description = "The name of the peering from hub to spoke"
  type        = string
   
  
}

variable "spoke_to_hub_peering_name" {
  description = "The name of the peering from spoke to hub"
  type        = string

}

# variable "subscription_id" {
#   description = "The Azure subscription ID where resources will be created"
#   type        = string
#   sensitive = true

# }
