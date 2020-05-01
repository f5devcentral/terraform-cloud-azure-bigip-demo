variable "specification" {
  # must select a region that supports availability zones
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
default = {
    production = {
      region             = "eastus"
      azs                = ["1"]
      application_count  = 3
      environment        = "productionB"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 2
      gtm_instance_count = 1
    }
    blue = {
      region             = "eastus"
      azs                = ["1","3"]
      application_count  = 4
      environment        = "productionBlue"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 2
      gtm_instance_count = 0
    }
    green = {
      region             = "eastus"
      azs                = ["1","3"]
      application_count  = 4
      environment        = "productionGreen"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 2
      gtm_instance_count = 0
    }
    development = {
      region             = "westus2"
      azs                = ["1"]
      application_count  = 3
      environment        = "demowest"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 2
      gtm_instance_count = 0
    }
    test = {
      region             = "centralus"
      azs                = ["1"]
      application_count  = 3
      environment        = "democentral"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 2
      gtm_instance_count = 0
    }
    default = {
      region             = "westus2"
      azs                = ["1", "3"]
      application_count  = 2
      environment        = "demodefault"
      cidr               = "10.0.0.0/8"
      ltm_instance_count = 1
      gtm_instance_count = 1
    }
  }
}
variable "specification_name" {
  default = "default"
  description = "name of the map within specification to use for the build"
}

# Application Server 
variable "appsvr_instance_type" {
  default = "Standard_B2s" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
}

# Telemetry Server 
variable "telemetrysvr_instance_type" {
  default = "Standard_D2s_v3" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
}

# Jumphost Server
variable "jumphost_instance_type" {
  default = "Standard_B2s" # https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
}

variable "prefix" {
  default = "f5d"
}
variable "publickeyfile" {
  description = "public key for server builds"
}
# BIGIP Image
# https://github.com/F5Networks/f5-azure-arm-templates/blob/v7.0.0.2/supported/standalone/1nic/new-stack/payg/azuredeploy.json
variable instance_type { default = "Standard_DS3_v2" }
variable image_name { default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable product { default = "f5-big-ip-best" }
variable bigip_version { default = "14.1.003000" }

# remove when 15.1 is in the marketplace
variable image_id { default = "/subscriptions/aacd7ba7-e47c-4cb7-a8b7-90f81fdd3865/resourceGroups/cody-rg/providers/Microsoft.Compute/galleries/WWCloudSA/images/f5-bigip-15.1" }

variable "admin_username" {
  description = "BIG-IP administrative user"
  default     = "azureuser"
}
## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable DO_URL {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.11.0/f5-declarative-onboarding-1.11.0-1.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable AS3_URL {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.18.0/f5-appsvcs-3.18.0-4.noarch.rpm"
}
## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable TS_URL {
  description = "URL to download the BIG-IP Telemetry Streaming Extension (TS) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.10.0/f5-telemetry-1.10.0-2.noarch.rpm"
}
variable "libs_dir" {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  type        = string
  default     = "/config/cloud/aws/node_modules"
}

variable onboard_log {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  type        = string
  default     = "/var/log/startup-script.log"
}

variable "ARM_CLIENT" {}
variable "ARM_CLIENT_SECRETS" {}
variable "ARM_SUBSCRIPTION" {}
variable "ARM_TENANT" {}

