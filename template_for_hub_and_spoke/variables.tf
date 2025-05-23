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

variable "password" {
  description = "Password for linuxvm"
  type = string
  sensitive = true
}



variable "username" {
  description = "username for linuxvm"
  type = string
  sensitive = true
}


