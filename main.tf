# Set the Azure provider source and version being used
/* terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
    }
    }
} */
# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {} #Features block is required
    }

# Create resource group
resource "azurerm_resource_group" "linux-rg" {
    name        = "linux-rg"
    location    = "westus2"
    tags        = {
        environment = "test"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "linux-vnet" {
    name                = "linux-vnet"
    resource_group_name = azurerm_resource_group.linux-rg.name
    location            = azurerm_resource_group.linux-rg.location
    address_space       = ["10.0.0.0/16"]

    tags = {
        environment = "test"
    }
}
# Create subnet within our virtual network. Best practice as a separate resource
resource "azurerm_subnet" "linux-subnet" {
    name                 = "linux-subnet"
    resource_group_name  = azurerm_resource_group.linux-rg.name
    virtual_network_name = azurerm_virtual_network.linux-vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}
# Create our Network Security Group (NSG)
resource "azurerm_network_security_group" "linux-nsg" {
    name                = "linux-nsg"
    location            = azurerm_resource_group.linux-rg.location
    resource_group_name = azurerm_resource_group.linux-rg.name
    tags = {
        environment = "dev"
    }
}
# Create our Network Security Rule separate of our NSG
resource "azurerm_network_security_rule" "linux-sg-rule" {
    name                        = "allow_all"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.linux-rg.name
    network_security_group_name = azurerm_network_security_group.linux-nsg.name
}
# Create the NSG association
resource "azurerm_subnet_network_security_group_association" "linux-ssgassoc" {
    subnet_id                 = azurerm_subnet.linux-subnet.id
    network_security_group_id = azurerm_network_security_group.linux-nsg.id
    }
# Create public ip for linux VM so we can eventually connect to it
resource "azurerm_public_ip" "linux-ip" {
    name                = "linux-ip"
    resource_group_name = azurerm_resource_group.linux-rg.name
    location            = azurerm_resource_group.linux-rg.location
    allocation_method   = "Dynamic"

    tags = {
    environment = "test"
        }
}
# Create Linux public Ip
resource "azurerm_network_interface" "linux-nic" {
    name                = "linux-nic"
    location            = azurerm_resource_group.linux-rg.location
    resource_group_name = azurerm_resource_group.linux-rg.name

    ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.linux-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-ip.id
    }
    tags = {
    environment = "test"
    }
}

# Create Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux-vm" {
    name                  = "linux-vm"
    resource_group_name   = azurerm_resource_group.linux-rg.name
    location              = azurerm_resource_group.linux-rg.location
    size                  = "Standard_F2"
    admin_username        = "adminuser"
    network_interface_ids = [azurerm_network_interface.linux-nic.id]
    # Add the file path for the ssh key pair that we generated  
    admin_ssh_key {
        username   = "adminuser"
        public_key = file("C:\\Users\\Clinton\\azure.pub") # Pass the file path as recorded in previous step
    }
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}