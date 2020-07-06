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

### An experiment to try
If you look at [vs_as3.json](vs_as3.json) you'll find the following stanza within the declaration.
```json
"ASM_Policy": {
    "class": "WAF_Policy",
    "url": "https://github.com/mjmenger/waf-policy/raw/0.1.0/asm_policy.xml",
    "ignoreChanges": false
}  
```
This stanza references a [version controlled XML export of a WAF policy](https://github.com/mjmenger/waf-policy/blob/0.1.0/asm_policy.xml). This version is tagged with *0.1.0*. There is another version tagged with *0.2.0*. Try updating the reference to the other version and merge it into the branch of a running environment. See what happens in Terraform Cloud and what happens within your F5 BIG-IP instances. 

### Another experiment to try
if you look at [variables.tf](variables.tf) you'll find blocks of environment definitions that look like the following;
```json
development = {
    region            = "westus2"
    azs               = ["1"]
    application_count = 3
    environment       = "demowest"
    cidr              = "10.0.0.0/8"
    ltm_instance_count = 2
    gtm_instance_count = 0
}
```
in a fashion similar to the previous experiment, adjust the value of *application_count* to add one or two more application servers. After you've merged the change and the apply completes in Terraform Cloud, watch what happens to the pool in your BIG-IPs as F5 BIG-IP's Service Discovery works its magic.


[queueplan]:doc_assets/queuetheplan.png



