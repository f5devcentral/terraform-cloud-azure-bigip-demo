locals {
  application_count = var.specification[var.specification_name]["application_count"]
}

# Create virtual machine
resource "azurerm_virtual_machine" "appserver" {
  count                 = length(local.azs) * local.application_count # all applications are duplicated across availability zones
  name                  = format("%s-appserver-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.app_nic[count.index].id]
  vm_size               = var.appsvr_instance_type
  zones                 = [element(local.azs, count.index)]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # if this is set to false there are behaviors that will require manual intervention
  # if tainting the virtual machine
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = format("%s-appserver-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = format("%s-appserver-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    admin_username = "azureuser"
    custom_data    = base64encode(file("${path.module}/appserverinit.yaml"))
  }



  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = var.publickeyfile
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = var.specification[var.specification_name]["environment"]
    # for BIG-IP Service Discovery to work, the discovery tags on the NIC 
    # must be passed to the BIG-IP. The Azure service discovery looks at 
    # the NICs, not the VMs
    workload    = "nginx"
  }
}

# Create network interface
resource "azurerm_network_interface" "app_nic" {
  count                     = length(local.azs) * local.application_count
  name                      = format("%s-app-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  #network_security_group_id = azurerm_network_security_group.app_sg.id

  ip_configuration {
    name                          = format("%s-app-nic-%s-%s", var.prefix, count.index, random_id.randomId.hex)
    subnet_id                     = azurerm_subnet.private[count.index % length(local.azs)].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.specification[var.specification_name]["environment"]
    # for BIG-IP Service Discovery to work the discovery tags on the NIC 
    # must be passed to the BIG-IP. The Azure service discovery looks at 
    # the NICs, not the VMs
    workload    = "nginx"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "app_sg" {
  name                = format("%s-app_sg-%s", var.prefix, random_id.randomId.hex)
  location            = var.specification[var.specification_name]["region"]
  resource_group_name = azurerm_resource_group.main.name

  # extend the set of security rules to address the needs of
  # the applications deployed on the application server
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.cidr # only allow traffic from within the virtual network
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = local.cidr # only allow traffic from within the virtual network
    destination_address_prefix = "*"
  }


  tags = {
    environment = var.specification[var.specification_name]["environment"]
  }
}


resource "null_resource" "virtualserverAS3" {
  count = local.ltm_instance_count
  # cluster owner node
  provisioner "local-exec" {
    command = <<-EOT
        curl -s -k -X POST https://${azurerm_public_ip.management_public_ip[count.index].ip_address}:443/mgmt/shared/appsvcs/declare \
              -H 'Content-Type: application/json' \
              --max-time 600 \
              --retry 10 \
              --retry-delay 30 \
              --retry-max-time 600 \
              --retry-connrefused \
              -u "admin:${random_password.bigippassword.result}" \
              -d '${data.template_file.virtualserverAS3[count.index].rendered}'
        EOT
  }

  depends_on = [
    azurerm_linux_virtual_machine.f5bigip,
    azurerm_virtual_machine_extension.run_startup_cmd
  ]
}

data "template_file" "virtualserverAS3" {
  count    = local.ltm_instance_count
  template = file("${path.module}/vs_as3.json")
  vars     = {
    as3_id                  = random_string.as3id.result
    application_external_ip = jsonencode(azurerm_network_interface.ext-nic[count.index].private_ip_addresses[1])
    pool_members            = jsonencode(azurerm_network_interface.app_nic[*].private_ip_address)
    azure_resource_group    = azurerm_resource_group.main.name
    azure_subcription_id    = var.ARM_SUBSCRIPTION
    azure_tenant_id         = var.ARM_TENANT
    azure_client_id         = var.ARM_CLIENT
    azure_client_secret     = var.ARM_CLIENT_SECRETS
  }
}

resource "random_string" "as3id" {
  length = 25
  special = false
}