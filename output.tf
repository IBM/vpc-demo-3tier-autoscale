
output "lb_front" {
    value = "http://${local.lb_web}/"
}

output "lb_back" {
    value = "http://${local.lb_app}:8000/"
}

output "instances" {
    value = {
      for instance in local.instance_expansion : "${instance.vpc_name}-${instance.zone_name}-${instance.instance_name}" => {
        primary_ip = module.vpc-instance["${instance.vpc_name}-${instance.zone_name}-${instance.instance_name}"].primary_ip[0][0]
        floating_ip = module.vpc-instance["${instance.vpc_name}-${instance.zone_name}-${instance.instance_name}"].floating_ip
      } if instance.type == "instance"
    }
}