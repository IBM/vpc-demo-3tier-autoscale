#####################################################
# Sysdig instance key
# Copyright 2020 IBM
#####################################################

data "ibm_resource_instance" "sysdig" {
  count = var.provision ? 0 : 1

  name              = var.name
  location          = var.region
  resource_group_id = var.resource_group_id
  service           = "sysdig-monitor"
}

resource "ibm_resource_instance" "sysdig_instance" {

  count = var.provision ? 1 : 0

  name              = var.name
  service           = "sysdig-monitor"
  plan              = var.plan
  location          = var.region
  resource_group_id = var.resource_group_id
  tags              = (var.tags != null ? var.tags : [])
  service_endpoints = (var.service_endpoints != "" ? var.service_endpoints : null)
  parameters = {
    "default_receiver" = var.enable_platform_metrics
  }

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    update = (var.update_timeout != null ? var.update_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }
}

resource "ibm_resource_key" "sysdig_key" {
  count                = var.bind_key ? 1 : 0
  name                 = var.key_name
  role                 = "Manager"
  resource_instance_id = var.provision ? ibm_resource_instance.sysdig_instance[0].id : data.ibm_resource_instance.sysdig[0].id
  tags                 = (var.key_tags != null ? var.key_tags : [])
}

output "sysdig_instance" {
  value = ibm_resource_instance.sysdig_instance
}

