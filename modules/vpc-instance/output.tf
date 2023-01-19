
output "instance_ids" {
  description = "The ID of the Instances"
  value       = ibm_is_instance.instances.*.id
}

output "primary_network_interfaces" {
  description = "The primary_network_interface of the Instances"
  value       = [for ins in ibm_is_instance.instances : ins.primary_network_interface.*.id]
}

output "primary_ip" {

  description = "The primary ip address attached to the primary network interface"
  value       = [for ins in ibm_is_instance.instances : ins.primary_network_interface.*.primary_ipv4_address]

}

output "floating_ip" {

  description = "Floating point IP if assigned"
  value       = var.floating_ip ? ibm_is_floating_ip.instance_floating_ip[0].address : null
}