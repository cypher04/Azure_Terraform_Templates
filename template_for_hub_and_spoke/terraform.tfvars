

location = "West US"


resource_group_name = "rg-hub-spoke-demo"


hub_vnet = { name = "vnet-hub", address_space = ["10.0.0.0/16"], subnet_prefix = "10.0.1.0/24" }


spokes = [ { name = "vnet-spoke-1", address_space = ["10.1.0.0/16"], subnet_prefix = "10.1.1.0/24" }, { name = "vnet-spoke-2", address_space = ["10.2.0.0/16"], subnet_prefix = "10.2.0.0/24" } ]

# firewall_subnet = { name = "AzureFirewallSubnet", address_prefixes = " 10.0.2.0/26" }


tags = { environment = "demo" }


password = "P@ssw0rd1234!"

username = "adminuser"


ssh_public_key = "/User/seyiabiodun/.ssh/id_rsa.pub"

firewall_subnet_prefix = "10.0.2.0/26"

    

