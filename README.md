## Managing F5 BIG-IP deployments in Azure with HashiCorp Terraform Cloud
This repository uses [Terraform Cloud](https://app.terraform.io/) to manage multiple parallel environment builds. Before you can run the demonstration code there are a few setup steps.

First, let's do the necessary [prework](PREWORK.md) before we can create the Terraform Cloud Workspace.

Now that we've configured the Azure account, created a Service Principal, and set up your own copy of this repository we can [create a Terraform Cloud Workspace](TFCWORKSPACE.md).  

With the workspace in place we need to [setup the variables](TFCVARS.md) that are necessary for the workspace to create a plan and an apply.

After those steps, you should now be ready to kick the tires by queuing a plan
![queue the plan][queueplan]



### Workspace Configuration
In the variables.tf there is a `specification` variable that contains HCL maps. The one in use for your workspace is identified in the **specification_name** variable you setup during the [variables steps](TFCVARS.md). For example, the map below is used when setting **specification_name** to **east**

```
east = {
    region             = "eastus"     # the azure region to build in
    azs                = ["1"]        # availability zones to build in
    application_count  = 3            # the number of application servers to build per AZ
    environment        = "demoeast"   # a label to tag build assets with
    cidr               = "10.0.0.0/8" # the base cidr of the virtual network
    ltm_instance_count = 2            # the number of ltm BIG-IPs to build
    gtm_instance_count = 1            # the number of gtm BIG-IPs to build
}
```

Do the following if you need to create support for another branch/environment.
- duplicate an existing map
- add it to the array
- adjust values as appropriate 

For example, if you need to add support for `francecentral` you could do as follows;

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



