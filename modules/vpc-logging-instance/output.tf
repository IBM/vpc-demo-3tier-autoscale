#####################################################
# Set up a Logging Super Tenant Sender (STS) instance
# Copyright 2020 IBM
#####################################################

output "id" {
  description = "The ID of the logging STS instance"
  value       = var.provision ? concat(ibm_resource_instance.logging_instance.*.id, [""])[0] : concat(data.ibm_resource_instance.logging_instance.*.id, [""])[0]
}

output "guid" {
  description = "The GUID of the logging STS instance"
  value       = var.provision ? concat(ibm_resource_instance.logging_instance.*.guid, [""])[0] : concat(data.ibm_resource_instance.logging_instance.*.guid, [""])[0]
}

output "key_id" {
  description = "ID of the logging STS instance key"
  value       = concat(ibm_resource_key.logging_key.*.id, [""])[0]
}

output "key_guid" {
  description = "logging STS key guid"
  value       = concat(ibm_resource_key.logging_key.*.guid, [""])[0]
}

output "key_credentials" {
  description = "logging STS key credentials"
  value       = concat(ibm_resource_key.logging_key.*.credentials, [""])[0]
}