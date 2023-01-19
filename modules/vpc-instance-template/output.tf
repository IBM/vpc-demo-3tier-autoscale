
output "instance_template_id" {
  description = "The ID of the Instance Template"
  value       = ibm_is_instance_template.instance_template.id
}