terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}

subscription_id = "9bdf6b94-c50c-4937-9036-ac5b12db1f96"
client_id       = "f5c0610d-85d4-42be-9c5a-28fdac924971"
client_secret   = "baf8Q~oDg_ly5qJ_PuwOB2XZqfdQMgeHeJcIGcmI"
tenant_id       = "92f81780-1969-48f6-984f-a127442554eb"

}
resource "azurerm_resource_group" "rg" {
  name     = "MPK"
  location = "East US"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "mpkvnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
resource "azurerm_public_ip" "Public_IP" {
  name                = "public_ip"
  location            = azurerm_resource_group.rg.location #value = azurerm_public_ip.Public_IP.ip_address
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "Load_Balancer" {
  name                = "Load_Balancer"
  location            = azurerm_resource_group.rg.location 
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    # public_ip_address_id = azurerm_public_ip.public_ip_address.id
    public_ip_address_id = azurerm_public_ip.Public_IP.id
  }
}
resource "azurerm_linux_virtual_machine" "VM" {
  count                 = 2
  name                  = "MPK-vm-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.Networkinterface[count.index].id]
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  admin_password        = "Password12345!" # Replace with your SSH public key or password
  os_disk {
    name              = "OS-osdisk-${count.index}"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "Networkinterface" {
  count               = 2
  name                = "Networkinterface-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "MPK" {
  name                = "MPK-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_network_interface_security_group_association" "ASGS" {
  count               = 2
  network_interface_id = azurerm_network_interface.Networkinterface[count.index].id
 # network_interface_ids = [azurerm_network_interface.Networkinterface[count.index].id]
  network_security_group_id = azurerm_network_security_group .MPK.id
}
output "public_ip_address" {
  value = azurerm_public_ip.Public_IP.ip_address
}

output "Load_Balancer_ip_address" {
  #value = azurerm_lb.Load_Balancer.frontend_ip_configuration[0].Public_IP.id
  value = azurerm_lb.Load_Balancer.id
}