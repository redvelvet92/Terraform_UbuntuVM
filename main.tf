# This Terraform configuration will create the following:
#
# This will create a Resource group with a virtual network and subnet
# It will also create a Ubuntu Virtual Machine
# All Variables are pulled from Variables.tf


# Resource Group
resource "azurerm_resource_group" "usnc-ubuntu-test" {
    name = "${var.resourcegroup}"
    location = "${var.location}"
    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}

resource "azurerm_virtual_network" "usnc-teds-vnet" {
    name = "${var.virtualnetwork}"
    location = "${var.location}"
    address_space = ["${var.address_space}"]
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}

resource "azurerm_subnet" "subnet" {
    name = "${var.subnet}"
    location = "${var.location}"
    address_prefix ="${var.address_prefix}"
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}

resource "azurerm_network_security_group" "usnc-teds-nsg" {
    name = "${var.network_security_group}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    
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
    name = "ssh"
    priority = 101
    direction = "Inbound"
    access = "allow"
    protocol = "tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "${var.source_network}"
    destination_address_prefix = "*"
    }

    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}
resource "azurerm_network_interface" "usnc-ubuntu-nic" {
    name = "${var.prefix}usnc-ubuntu-nic"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    network_security_group_id = "${azurerm_network_security_group.usnc-teds-nsg.id}"


    ip_configuration {
        name = "${var.prefix}ipconfig"
        subnet_id = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.usnc-ubuntu-pip.id}"
    }

    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}


resource "azurerm_public_ip" "usnc-ubuntu-pip" {
    name = "${var.prefix}-ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label = "${var.hostname}"

    tags {
        Environment = "Ubuntu Terraform Deployment"
    }
}

resource "azurerm_virtual_machine" "usnc-ubuntu-vm" {
    name = "${var.hostname}-ubuntu"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc-ubuntu-test.name}"
    vm_size = "${var.vmsize}"
    network_interface_ids =  ["${var.usnc-ubuntu-nic.id}"]

    storage_image_reference {
        publish = "Canonical"
        offer = "UbuntuServer"
        sku = "16.04-LTS"
        version = "latest"
    }
    storage_os_disk {
        name = "${var.hostname}-osdisk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "${var.hostname}"
        admin_username = "${var.username}"
        admin_password = "${var.password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }    

    tags {
        Environment = "Ubuntu Terraform Deployment"
    }

}




