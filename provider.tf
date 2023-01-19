##############################################################
# Terraform declaration
##############################################################

terraform {
  required_version = ">= 1.00"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.44.0"
    }
  }
}

##############################################################
# Terraform Provider declaration
##############################################################

provider "ibm" {

# Define Provider inputs from given Terraform Variables
  ibmcloud_api_key = var.ibmcloud_api_key

# Default Provider block parameters
  region = var.region
}