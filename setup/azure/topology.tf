provider "azurerm" {
  tenant_id = "06525c31-7149-4c7d-9049-7d164861fa25"
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
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path      = "/home/ubuntu/.ssh/authorized_keys"
      key_data  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZJNeL5dg9nZfStOJNF6MEy9rhsFsBekX8poAxv35XenBvWWISa/ZW0r4YZmnyGniQGmKJH+XPnRJccDvm2b4r+kyA3AcIRzUVNPXu9+9Tg8viBH0lOp4YZdmACBzBgZS7Otp/JRfWujFZf9Uy3QmQVEC6ByIdhzMMfgSFF/hgBveXPMgSNwIpUn6i3Xvxu1rzUgWbZ45+fB3VYvkM77tbQ89p62NiIdrDlztAhVTtaDTBW++GwnU3bvv4hz/oZBkihO+YB5yV9EhltV5ts7l+Ac3k0v68Pu5pzkYn9INobXn4oeDNrZWFyc70HWfQGIt9uVh8+nW2prZpvsTgAHcGfPfRv0JHTjeFmWcmc1NbbWo9+OwmOfO7dzJoG8TXa6Fi1aEJ2Qsgp0MZGiV//5v33nE1bTRU//db+L/dvlH1YKM4gpupDzBpgqnWSVEvibib+vA+sXuG2l7f6NB6uGMjcosHVFcE39QzXSX+0RsiCuPsUTqymAmafDvxagLzBodK+jQDWGxaWu38nSZufto01mJRHqvaTrTo++QpevjzhJD3I5U7qliwaCb6YnBVOJNOg3eq84N8yTKJHQQcXt+ZgB+xbxeB3OdY3EIhVzY0leOWSu/Osr3irq+X/gVxmnkQQ5vK0EU7aZS0L57zBOKv6xxcevTttmqgSyZOy6Nw/w=="
    } 
  }
  tags = {
    environment = "staging"
    trigramme   = "${var.trigramme}"
  }
}
