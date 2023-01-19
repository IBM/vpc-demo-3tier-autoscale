#####################################################
# Set up Activity Tracker Super Tenant Sender (ATS) instance
# Copyright 2020 IBM
#####################################################

output "id" {
  description = "ID of Activity Tracker ATS"
  value       = var.provision ? concat(ibm_resource_instance.activity_tracker.*.id, [""])[0] : concat(data.ibm_resource_instance.activity_tracker.*.id, [""])[0]
}

output "guid" {
  description = "The GUID of the activity tracker"
  value       = var.provision ? concat(ibm_resource_instance.activity_tracker.*.guid, [""])[0] : concat(data.ibm_resource_instance.activity_tracker.*.guid, [""])[0]
}

output "key_id" {
  description = "Activity Tracker ATS key id"
  value       = concat(ibm_resource_key.activity_tracker_key.*.id, [""])[0]
}

output "key_guid" {
  description = "Activity Tracker ATS key guid"
  value       = concat(ibm_resource_key.activity_tracker_key.*.guid, [""])[0]
}

output "key_credentials" {
  description = "Activity Tracker ATS key credentials"
  value       = concat(ibm_resource_key.activity_tracker_key.*.credentials, [""])[0]
}