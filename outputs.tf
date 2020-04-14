output "workspace" {
  value = var.specification_name
}

output "hex_label" {
  value = random_id.randomId.hex
}

output "bigip_mgmt_public_ips" {
  value = azurerm_public_ip.management_public_ip[*].ip_address
}

output "bigip_mgmt_port" {
  value = "443"
}

output "bigip_password" {
  value = random_password.bigippassword.result
}

output "jumphost_ip" {
  value = azurerm_public_ip.jh_public_ip[*].ip_address
}

output "nginx_ip" {
  value = azurerm_public_ip.juiceshop_public_ip[*].ip_address
}
