# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix[terraform.workspace]}-rg"
  location = var.resource_group_location[terraform.workspace]
  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix[terraform.workspace]}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_prefix[terraform.workspace]}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.resource_prefix[terraform.workspace]}-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_prefix[terraform.workspace]}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.resource_prefix[terraform.workspace]}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "linuxvm" {
  name                  = "${var.resource_prefix[terraform.workspace]}-LinuxVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size                  = "Standard_A1_v2"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "OpenLogic"
    offer = "CentOS"
    sku = "7.5"
    version = "latest"
  }
  storage_os_disk {
    name = "myosdisk-${var.resource_prefix[terraform.workspace]}"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "linuxhost-${var.resource_prefix[terraform.workspace]}"
    admin_username = "raviarora"
    admin_password = "raviarora@123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.environment_tag[terraform.workspace]
  }
}