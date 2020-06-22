resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "vm_sg" {
  name                = "vm-sg"
  location            = var.location
  resource_group_name = var.resource_group

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

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "vmNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id
}


resource "random_string" "storagesuffix" {
  keepers = {
    resource_group = var.resource_group
  }

  length  = 13
  upper   = false
  special = false
}

resource "azurerm_storage_account" "vm_storage" {
  name                     = "jumpstorage${random_string.storagesuffix.result}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "tls_private_key" "jumpbox_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "jumpboxvm"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "jumpboxOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  computer_name                   = "jumpboxvm"
  admin_username                  = var.vm_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_user
    public_key = tls_private_key.jumpbox_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_storage.primary_blob_endpoint
  }
}