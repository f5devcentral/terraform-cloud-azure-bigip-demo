This terraform repository uses [Terraform Cloud](https://app.terraform.io/) to manage multiple parallel builds. 

### Create Service Principal for authentication and authorization
We're using a Service Principal with Terraform and Azure as described [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html). We've distilled the key steps below, but it's worth reading the source document for more detail. The following assumes that you have the Azure CLI installed. If you don't have it installed yet, [please do](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

```bash
az login

az account list
```
If your account list is longer than one please verify that the default account is the one you'd like to use with this demonstration. If it isn't the default account, you can use the following command to adjust the default account.
```bash
az account set --subscription="SUBSCRIPTION_ID"
```
We'll now create the Service Principal
```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```
which returns something like this
```bash
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```
We'll be using the values for appId, password, and tenant later. Please treat these values as sensitive data as they can be used to make significant changes within your Azure account.

### Accept Terms of F5 Pay As You Go image
This demonstration uses the F5 BIG-IP Pay As You Go license. There are blocks within the code that allow you to use a BIG-IP license or a BIG-IQ license server. However, this README focuses on the use of the hourly image. Before proceeding, your account needs to accept the terms of use for the hourly image, which you can do with the following command. 
```bash
az vm image terms accept --plan "f5-bigip-virtual-edition-25m-best-hourly" --offer "f5-big-ip-best" --publisher "f5-networks"
```
### Create a SSH key pair
Create the key pair you intend to use for the environment builds. It is highly recommended that you use a keypair expressly for these builds, so that if it is compromised for any reason the breadth of impact is limited to these environments. In other words, don't use the key pair you use for production operations. 
```bash
ssh-keygen -m PEM -t rsa 
```
### Setup a VCS Provider reference
If you don't already have account on [Terraform Cloud](https://app.terraform.io), please create one.

When you are logged into you Terraform Cloud account select organization settings  
![click org settings][orgsettings | width=150]  

and then select VCS Providers and follow the instructions to setup a provider for the repository containing your fork of this repository.  
![click vcs providers][vcsproviders]  

### Setup a Terraform Cloud Workspace
Once the VCS provider is setup, show the organization Workspaces page.  
![click org settings][orgsettings]  
On the workspaces page, select the New Workspace button.  
![click + New Workspace][newworkspace]  

![select the vcs provider][selectvcs]  

![select the repository][selectrepo]  

![setup the repo][reposettings]  

and click Create workspace  


kick the tires, and then



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


[orgsettings]:doc_assets/orgsettings.png
[vcsproviders]:doc_assets/vcssettings.png
[newworkspace]:doc_assets/newworkspace.png
[vcssettings]:doc_assets/vcssettings.png
[waitingforconfig]:doc_assets/waitingforrepoconfig.png
[terraformvariables]:doc_assets/terraformvariables.png
[environmentvariables]:doc_assets/environmentvariables.png
[selectrepo]:doc_assets/selectrepository.png
[selectvcs]:doc_assets/selectvsprovider.png
[reposettings]:doc_assets/repositorysettings.png




