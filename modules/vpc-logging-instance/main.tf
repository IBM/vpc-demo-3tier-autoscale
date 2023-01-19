#####################################################
# Set up a Logging Super Tenant Sender (STS) instance
# Copyright 2020 IBM
#####################################################

locals {

  # logging sts instance validation - 'service_supertenant' and 'provision_key' variables must be passed when 'provision = true'
  logging_sts_validate_condition = (var.is_sts_instance == true && (var.service_supertenant == null || var.provision_key == null))
  logging_sts_validate_msg       = "Values for 'service_supertenant' and 'provision_key' variables must be passed when 'is_sts_instance = true'"
  # tflint-ignore: terraform_unused_declarations
  logging_sts_validate_check = regex("^${local.logging_sts_validate_msg}$", (!local.logging_sts_validate_condition ? local.logging_sts_validate_msg : ""))

  # bind key validation - 'key_name' variable must be passed when 'bind_key = true
  bindkey_validate_condition = var.bind_key == true && (var.key_name == null)
  bindkey_validate_msg       = "Value for 'key_name' variable must be passed when 'bind_key = true'"
  # tflint-ignore: terraform_unused_declarations
  bindkey_validate_check = regex("^${local.bindkey_validate_msg}$", (!local.bindkey_validate_condition ? local.bindkey_validate_msg : ""))

  # parameters for STS logging instance
  sts_parameters = {
    "service_supertenant" = var.service_supertenant
    "provision_key"       = var.provision_key
  }

  # parameters for STR logging instance
  str_parameters = {
    "default_receiver" = var.enable_platform_logs
  }
}

data "ibm_resource_instance" "logging_instance" {
  count = var.provision ? 0 : 1

  name              = var.name
  location          = var.region
#  resource_group_id = var.resource_group_id
  service           = "logdna"
}

resource "ibm_resource_instance" "logging_instance" {
  count = var.provision ? 1 : 0

  name              = var.name
  service           = "logdna"
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = (var.tags != null ? var.tags : null)
  service_endpoints = (var.service_endpoints != null ? var.service_endpoints : null)
  parameters        = var.is_sts_instance ? local.sts_parameters : local.str_parameters

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    update = (var.update_timeout != null ? var.update_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }

  # Ignore changes to provision key, it changes every quarter.
  lifecycle {
    ignore_changes = [parameters["provision_key"]]
  }
}

resource "ibm_resource_key" "logging_key" {
  count                = var.bind_key ? 1 : 0
  name                 = var.key_name
  role                 = "Manager"
  resource_instance_id = var.provision ? ibm_resource_instance.logging_instance[0].id : data.ibm_resource_instance.logging_instance[0].id
  tags                 = (var.key_tags != null ? var.key_tags : null)
}