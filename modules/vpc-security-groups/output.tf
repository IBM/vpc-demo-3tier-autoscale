
output "security_group_ids" {
  description = "The created security groups"
  value       = {
    for k, v in ibm_is_security_group.security_groups : k => v.id
  }
}

output "security_group_names" {
  description = "Map of security group to actual security group name"
  value       = {
    for k, v in ibm_is_security_group.security_groups : k => v.name
  }
}
