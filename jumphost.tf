# Create virtual machine
resource "azurerm_linux_virtual_machine" "jumphost" {
  count                        = length(local.azs)
  name                         = format("%s-jumphost-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  # removed for Azure 2.0 provider support
  #primary_network_interface_id   = azurerm_network_interface.jh_pub_nic[count.index].id
  network_interface_ids           = [azurerm_network_interface.jh_pub_nic[count.index].id, azurerm_network_interface.jh_priv_nic[count.index].id]
  size                            = var.jumphost_instance_type # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
  zone                            = element(local.azs, count.index)
  admin_username                  = var.admin_username
  admin_password                  = random_password.bigippassword.result
  disable_password_authentication = false

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # if this is set to false there are behaviors that will require manual intervention
  # if tainting the virtual machine
  #delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  #delete_data_disks_on_termination = true
  os_disk {
    name              = format("%s-jumphost-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    caching           = "ReadWrite"
    #create_option     = "FromImage"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # os_profile {
  #   computer_name  = format("%s-jumphost-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  #   admin_username = "azureuser"
  # }

  # os_profile_linux_config {
  #   disable_password_authentication = true
  #   ssh_keys {
  #     path     = "/home/azureuser/.ssh/authorized_keys"
  #     key_data = file(var.publickeyfile)
  #   }
  # }
  admin_ssh_key {
    username = var.admin_username
    public_key = var.publickeyfile
  }

  boot_diagnostics {
    #enabled             = "true"
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = var.specification[var.specification_name]["environment"]
    workload    = "jumphost"
  }
}

# Create network interface
resource "azurerm_network_interface" "jh_pub_nic" {
  count                     = length(local.azs)
  name                      = format("%s-jh-pub-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  #network_security_group_id = azurerm_network_security_group.jh_sg.id

  ip_configuration {
    primary                       = true
    name                          = format("%s-jh-pub-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    subnet_id                     = azurerm_subnet.public[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jh_public_ip[count.index].id
  }

  tags = {
    environment = var.specification[var.specification_name]["environment"]
  }
}

# Create network interface
resource "azurerm_network_interface" "jh_priv_nic" {
  count                     = length(local.azs)
  name                      = format("%s-jh-priv-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  #network_security_group_id = azurerm_network_security_group.jh_sg.id

  ip_configuration {
    name                          = format("%s-jh-priv-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    subnet_id                     = azurerm_subnet.private[count.index].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.specification[var.specification_name]["environment"]
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "jh_sg" {
  name                = format("%s-jh_sg-%s", var.prefix, random_id.randomId.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

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

  tags = {
    environment = var.specification[var.specification_name]["environment"]
  }
}

resource "azurerm_network_interface_security_group_association" "jh-pub-nic-security" {
  count                     = length(local.azs)
  network_interface_id      = azurerm_network_interface.jh_pub_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.jh_sg.id
}
resource "azurerm_network_interface_security_group_association" "jh-priv-nic-security" {
  count                     = length(local.azs)
  network_interface_id      = azurerm_network_interface.jh_priv_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.jh_sg.id
}


# Create public IPs
resource "azurerm_public_ip" "jh_public_ip" {
  count               = length(local.azs)
  name                = format("%s-jh-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"   # Static is required due to the use of the Standard sku
  sku                 = "Standard" # the Standard sku is required due to the use of availability zones
  zones               = [element(local.azs, count.index)]

  tags = {
    environment = var.specification[var.specification_name]["environment"]
  }
}