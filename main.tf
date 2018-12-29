# This Terraform configuration will create the following:
#
# This will create a Resource group with a virtual network and subnet
# It will also create a Ubuntu Virtual Machine
# All Variables are pulled from Variables.tf


# Resource Group
resource "azurerm_resource_group" "usnc-terraform-test" {
    name = "${var.resourcegroup}"
    location = "${var.location}"
    tags {
        Enviroment = "Teds Terraform Group"
    }
}

resource "azurerm_virtual_network" "usnc-teds-vnet" {
    name = "${var.virtualnetwork}"
    location = "${var.location}"
    address_space = ["${var.address_space}"]
    resource_group_name = "${var.resource_group_name.name}"
    tags {
        Enviroment = "Teds Terraform Group"
    }
}

resource "azurerm_subnet" "subnet" {
    name = "${var.subnet}"
    location = "${var.location}"
    address_prefix ="${var.address_prefix}"
    resource_group_name = "${var.resource_group_name.name}"
    tags {
        Environment = "Teds Terraform Group"
    }
}

##############################################################################
# * Build an Windows Server 2016 Datacenter VM
#
# Now that we have a network, we'll deploy an Windows Server 2016.
# An Azure Virtual Machine has several components. In this example we'll build
# a security group, a network interface, a public ip address, a storage 
# account and finally the VM itself. Terraform handles all the dependencies 
# automatically, and each resource is named with user-defined variables.



resource "azurerm_network_security_group" "usnc-teds-nsg" {
    name = "${var.network_security_group}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name.name}"
    
    security_rule {
    name = "HTTP"
    priority = 100
    direction ="Inbound"
    access = "allow"
    protocol = "tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "${var.source_network}"
    destination_address_prefix = "*"
    }

    security_rule {
    name = "RDP"
    priority = 101
    direction = "Inbound"
    access = "allow"
    protocol = "tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "${var.source_network}"
    destination_address_prefix = "*"
    }

    tags {
        Enviroment = "Teds Terraform Group"
    }
}
resource "azurerm_network_interface" "usnc-terraform-nic" {
    name = "${var.prefix}usnc-terraform-nic"
    location = "${var.location}"
    resource_group_name = "${var.azurerm_resource_group.name}"
    network_security_group_id = "${var.azurerm_network_security_group.usnc-teds-nsg}"


    ip_configuration {
        name = "${var.prefix}ipconfig"
        subnet_id = "${var.azurerm_subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${var.azurerm_public_ip.usnc-terraform-pip.id}"
    }

    tags {
        Enviroment = "Teds Terraform Group"
    }
}



