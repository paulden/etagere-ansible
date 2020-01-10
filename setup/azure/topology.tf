provider "azurerm" {
  tenant_id = "<YOUR_TENANT_ID>"
}

resource "azurerm_resource_group" "dojo" {
  name     = "${var.trigramme}-resources"
  location = "francecentral"
}

resource "azurerm_virtual_network" "dojo" {
  name                = "${var.trigramme}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.dojo.location}"
  resource_group_name = "${azurerm_resource_group.dojo.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.dojo.name}"
  virtual_network_name = "${azurerm_virtual_network.dojo.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "dojo" {
  name                = "${var.trigramme}-public-ip"
  location            = "${azurerm_resource_group.dojo.location}"
  resource_group_name = "${azurerm_resource_group.dojo.name}"
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "dojo" {
  name                = "${var.trigramme}-nic"
  location            = "${azurerm_resource_group.dojo.location}"
  resource_group_name = "${azurerm_resource_group.dojo.name}"

  ip_configuration {
    name                          = "dojoconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.dojo.id}"
  }
}

resource "azurerm_virtual_machine" "dojo" {
  name                  = "${var.trigramme}-vm"
  location              = "${azurerm_resource_group.dojo.location}"
  resource_group_name   = "${azurerm_resource_group.dojo.name}"
  network_interface_ids = ["${azurerm_network_interface.dojo.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osDisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "ubuntu"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path      = "/home/ubuntu/.ssh/authorized_keys"
      key_data  = "<YOUR_SSH_KEY>"
    } 
  }
  tags = {
    environment = "staging"
    trigramme   = "${var.trigramme}"
  }
}
