terraform show -json | jq '.values.root_module.resources[] | select(.address | contains("random_password.bigippassword"))  | .values.result' > inspec/bigip-ready/files/password.json
terraform show -json | jq '.values.root_module.resources[] | select(.address | contains("azurerm_public_ip.management_public_ip"))  | .values.ip_address ' > inspec/bigip-ready/files/mgmtips.json
inspec exec inspec/bigip-ready
