This terraform repository uses [Terraform Cloud](https://app.terraform.io/) to manage multiple parallel builds. 

First, let's do the necessary [prework](PREWORK.md) before we can create the Terraform Cloud Workspace.

Now that we've configured the Azure account, created a Service Principal, and set up your own copy of this repository we can [create a Terraform Cloud Workspace](TFCWORKSPACE.md).  

With the workspace in place we need to [setup the variables](TFCVARS.md) that are necessary for the workspace to create a plan and an apply.

After those steps, you should now be ready to kick the tires by queuing a plan
![queue the plan][queueplan]



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

[queueplan]:doc_assets/queuetheplan.png



