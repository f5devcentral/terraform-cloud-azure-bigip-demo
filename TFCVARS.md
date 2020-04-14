### Setup the variables  
In the Terraform Variables section set the following variables, setting the 'sensitive' flag for all of them but specification_name. The names are case-sensitive. The ARM_ variables are used to configure the service discovery package on the BIG-IPs.
- publickeyfile: the content of the public key you created during the [prework step](PREWORK.md)
- ARM_SUBSCRIPTION: your Azure subscription id 
- ARM_TENANT: your Azure tenant id created during the prework step, list as **tenant**
- ARM_CLIENT: your Azure client id created during the prework step, listed as **app_id**
- ARM_CLIENT_SECRETS: your client password created during the prework step, listed as **password**
- specification_name: the name of a configuration block within the specification map in variables.tf. for consistency it is suggested that this be the same as the corresponding branch in your source control repository
![terraform][terraformvariables]  

In the Environment Variables section set the following variables, setting the 'sensitive' flag for all of them. The names are case-sensitive. The ARM_ variables are used to configure azure_rm provider in Terraform.  

- ARM_SUBSCRIPTION_ID: your Azure subscription id 
- ARM_TENANT_ID: your Azure tenant id created during the prework step, list as **tenant**
- ARM_CLIENT_ID: your Azure client id created during the prework step, listed as **app_id**
- ARM_CLIENT_SECRET: your client password created during the prework step, listed as **password**

![environment][environmentvariables]  




[terraformvariables]:doc_assets/terraformvariables.png
[environmentvariables]:doc_assets/environmentvariables.png