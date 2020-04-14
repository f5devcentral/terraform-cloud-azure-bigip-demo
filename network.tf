locals{
    cidr = var.specification[var.specification_name]["cidr"]
    azs  = var.specification[var.specification_name]["azs"]
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
    name                = format("%s-vnet-%s",var.prefix,random_id.randomId.hex)
    address_space       = [local.cidr]
    location            = var.specification[var.specification_name]["region"]
    resource_group_name = azurerm_resource_group.main.name

    tags = {
        environment = var.specification[var.specification_name]["environment"]
    }
}

# Create management subnet
# resource "azurerm_subnet" "bastion" {
#     name                 = "AzureBastionSubnet"
#     resource_group_name  = azurerm_resource_group.main.name
#     virtual_network_name = azurerm_virtual_network.main.name
#     # address prefix 10.1x.0.0/24
#     address_prefix       = "10.40.0.0/24"
# }

# Create management subnet
resource "azurerm_subnet" "management" {
    count                = length(local.azs)
    name                 = format("%s-managementsubnet-%s-%s",var.prefix,count.index,random_id.randomId.hex)
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    # address prefix 10.1x.0.0/24
    address_prefix       = cidrsubnet(cidrsubnet(local.cidr, 8, 10 + count.index),8,0)
}
# Create public/external subnet
resource "azurerm_subnet" "public" {
    count                = length(local.azs)
    name                 = format("%s-publicsubnet-%s-%s",var.prefix,count.index,random_id.randomId.hex)
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    # address prefix 10.2x.0.0/24
    address_prefix       = cidrsubnet(cidrsubnet(local.cidr, 8, 20 + count.index),8,0)
}
# Create private/internal subnet
resource "azurerm_subnet" "private" {
    count                = length(local.azs)
    name                 = format("%s-privatesubnet-%s-%s",var.prefix,count.index,random_id.randomId.hex)
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    # address prefix 10.3x.0.0/24
    address_prefix       = cidrsubnet(cidrsubnet(local.cidr, 8, 30 + count.index),8,0)
}