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