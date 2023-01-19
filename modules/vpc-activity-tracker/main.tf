#####################################################
# Set up Activity Tracker Super Tenant Sender (ATS) instance
# Copyright 2020 IBM
#####################################################

locals {
  # when is_ats_instance is true, associated_logging_crn, service_supertenant and service_supertenant must be set
  ats_validate_condition = var.is_ats_instance == true && (var.service_supertenant == null || var.provision_key == null)
  ats_validate_msg       = "Values for 'service_supertenant' and 'provision_key' variables must be passed when 'is_ats_instance = true'"
  # tflint-ignore: terraform_unused_declarations
  ats_validate_check = regex("^${local.ats_validate_msg}$", (!local.ats_validate_condition ? local.ats_validate_msg : ""))

  # when bind_key is true, key_name has to be passed
  bindkey_validate_condition = var.bind_key == true && (var.key_name == null)
  bindkey_validate_msg       = "Values for 'key_name' variable must be passed when 'bind_key = true'"
  # tflint-ignore: terraform_unused_declarations
  bindkey_validate_check = regex("^${local.bindkey_validate_msg}$", (!local.bindkey_validate_condition ? local.bindkey_validate_msg : ""))

  # ATS parameter block
  ats_parameters = {
    "service_supertenant"    = var.service_supertenant
    "associated_logging_crn" = var.associated_logging_crn
    "provision_key"          = var.provision_key
  }

  # ATR parameter block
  atr_parameters = {
    "default_receiver" = var.make_default_receiver
  }

}

data "ibm_resource_instance" "activity_tracker" {
  count = var.provision ? 0 : 1

  name              = var.name
  location          = var.region
  resource_group_id = var.resource_group_id
  service           = "logdnaat"
}

resource "ibm_resource_instance" "activity_tracker" {
  count = var.provision ? 1 : 0

  name              = var.name
  service           = "logdnaat"
  plan              = var.plan
  location          = var.region
  resource_group_id = (var.resource_group_id != null ? var.resource_group_id : null)
  tags              = (var.tags != null ? var.tags : null)
  parameters        = var.is_ats_instance ? local.ats_parameters : local.atr_parameters


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

resource "ibm_resource_key" "activity_tracker_key" {
  count                = var.bind_key ? 1 : 0
  name                 = var.key_name
  role                 = "Manager"
  resource_instance_id = var.provision ? ibm_resource_instance.activity_tracker[0].id : data.ibm_resource_instance.activity_tracker[0].id
  tags                 = (var.key_tags != null ? var.key_tags : null)
}