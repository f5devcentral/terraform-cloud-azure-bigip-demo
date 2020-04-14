This terraform repository uses [workspaces](https://www.terraform.io/docs/state/workspaces.html) to manage multiple parallel builds. Workspace commands include, `new`, `list`, `show`, `select`, and `delete`. The details of how workspaces are used with this repository are described below. The elements of the build configuration that are controlled by the selected workspace are described at the end of this README.

some arbitrary text
some more text

az vm image terms accept --plan "f5-bigip-virtual-edition-25m-best-hourly" --offer "f5-big-ip-best" --publisher "f5-networks"


create the key pair you intend to use for the environment builds. it is highly recommended that you use a keypair expressly for these builds, so that if it is compromised for any reason the breadth of impact is limited to these environments.
```bash
ssh-keygen -m PEM -t rsa -f ./tftest
```
the first time you use one of the terraform workspaces you need to create it using the ```new``` action

```bash
terraform workspace new [east|west|central]
```
For example, if you intend to build in both the east and central workspaces you would do the following;

```bash
terraform workspace new east
terraform workspace new central
```
this will create a `terraform.tfstate.d` directory that will contain subdirectories for each workspace

at this point you can initialize the terraform repository 
```bash
terraform init
```
select the workspace you intend to use with the ```terraform workspace select action```. for example,
```bash
terraform workspace select east
```

Ensure you have an Azure access token before running ```terraform apply```.
```bash
az login
```

finally you can ```plan``` and ```apply``` the terraform repository
```bash
terraform plan -var "privatekeyfile=./tftest" -var "publickeyfile=./tftest.pub" -var "vault_id=asdf" -var "vault_resource_group=asdf" -var "bigip_password_secret_name=asdf" -var "service_principal_secret_name=asdf"
terraform apply -var "privatekeyfile=./tftest" -var "publickeyfile=./tftest.pub" -var "vault_id=asdf" -var "vault_resource_group=asdf" -var "bigip_password_secret_name=asdf" -var "service_principal_secret_name=asdf"
./runtest.sh
```

note: if you're using local state files, during an ```apply``` the state files are locked. This means you **can't** open another terminal window and select another workspace and try to run ```terraform apply```. (I may be wrong about this. An earlier version of terraform stored all of the workspace state in a single tfstate file. Since they're in separate files that may allow for parallel local builds)



kick the tires, and then
```bash
terraform workspace select [east|west|central]
terraform destroy -var "privatekeyfile=./tftest" -var "publickeyfile=./tftest.pub"
```

# Workspace Configuration
In the variables.tf there is a `specification` variable that contains HCL maps named with a reference to a workspace. For example, the map below is used when the east workspace is selected using ```terraform workspace select east```

```
        east = {
            region             = "eastus"
            azs                = ["1"]
            application_count  = 3
            environment        = "demoeast"
            cidr               = "10.0.0.0/8"
            ltm_instance_count = 2
            gtm_instance_count = 1
        }
```

if you need to create support for another workspace duplicate an existing map, add it to the array, and adjust values as appropriate. For example, if you need to add support for `francecentral` you could do as follows;

```
        east = {
            region             = "eastus"
            azs                = ["1"]
            application_count  = 3
            environment        = "demoeast"
            cidr               = "10.0.0.0/8"
            ltm_instance_count = 2
            gtm_instance_count = 1
        }
        francecentral = {
            region            = "francecentral"
            azs               = ["1"]
            application_count = 1
            environment       = "demofrcent"
            cidr              = "10.0.0.0/8"
            ltm_instance_count = 2
            gtm_instance_count = 0
        }
        west = {
            region            = "westus2"
            azs               = ["1"]
            application_count = 3
            environment       = "demowest"
            cidr              = "10.0.0.0/8"
            ltm_instance_count = 2
            gtm_instance_count = 0
        }



```