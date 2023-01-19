##############################################################
# Create Random Resource Prefix
##############################################################

# This random prefix will be added to given resource prefix to 
# make sure names are unique.

resource "random_string" "resource_code" {
  length  = 3
  special = false
  upper   = false
}

locals {
  resources_prefix = "${var.resource_prefix}-${random_string.resource_code.result}"
}

##############################################################
# Create Resource Group
##############################################################

resource "ibm_resource_group" "resource_group_vpc" {
  name     = "${local.resources_prefix}-${var.resource_group_name}"
}

data "ibm_resource_group" "resource_group_vpc" {
  name     = "${local.resources_prefix}-${var.resource_group_name}"
  depends_on = [
    ibm_resource_group.resource_group_vpc
  ]
}

##############################################################################
# Create Private keys (optional)
#    - Private Keys are required if the instance needs further scripts run
#      via terraform.
##############################################################################

# Public/Private key for accessing the instance, only valid for linux instances

resource "tls_private_key" "instance_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "write_instance_private_key" {
  content         = tls_private_key.instance_rsa.private_key_pem
  filename        = "SSH_KEYS/${local.resources_prefix}-instance_rsa"
  file_permission = 0600
}

resource "ibm_is_ssh_key" "instance_key" {
  name = "${local.resources_prefix}-instance-ssh-key"
  public_key = trimspace(tls_private_key.instance_rsa.public_key_openssh)
}

# User provided key
data "ibm_is_ssh_key" "user_provided_ssh_key" {
  name = var.ssh_key_name
}

##############################################################
# Create an IAM Access Group and Group Policy
# Which will contain the IAM Access Policies (which contain an 
# Access an Access Role for the service access and platform access)
##############################################################

resource "ibm_iam_access_group" "vpc_demo_access_group" {
  count       = var.deploy_iam ? 1 : 0 
  name        = "${local.resources_prefix}-vpc-demo-access-group"
  description = "Personnel who can provision resources into the Resource Group"
}

resource "ibm_iam_access_group_policy" "vpc_demo_platform_and_service_access_policy" {
  count           = var.deploy_iam ? 1 : 0
  access_group_id = ibm_iam_access_group.vpc_demo_access_group[count.index].id
  roles           = ["Operator", "Writer"]

  resources {
    resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  }
}

resource "ibm_iam_access_group_policy" "vpc_demo_group_access_policy" {
  count           = var.deploy_iam ? 1 : 0
  access_group_id = ibm_iam_access_group.vpc_demo_access_group[count.index].id
  roles           = ["Viewer"]

  resources {
    resource = data.ibm_resource_group.resource_group_vpc.id
    resource_type = "resource-group"
    resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  }

}
