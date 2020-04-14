### Fork this repository
[Fork](https://guides.github.com/activities/forking/) this repository into your own GitHub account.


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