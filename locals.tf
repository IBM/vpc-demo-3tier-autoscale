##########################################################################
# VPC Base Infrastructure Locals (VPC, Subnet, Instance, Load Balancer)
##########################################################################

# Convert a zone identifier to its associated number

locals {
    zone_name_2_id = {
        zone1 = "1"
        zone2 = "2"
        zone3 = "3"
    }
}

# ssh_keys for windows and linx, windows does not need a generated key

locals {
  ssh_keys = {
    windows = [ibm_is_ssh_key.instance_key.id]
    linux = [ibm_is_ssh_key.instance_key.id, data.ibm_is_ssh_key.user_provided_ssh_key.id]
  }
}

# A list of all expanded subnet details from var.vpc_infrastructure

locals { 

  subnet_expansion = flatten([
    for vpc_name, vpc in var.vpc_infrastructure : [
      for zone_name, zone in vpc.zones : [
        for subnet_name, subnet in zone.subnets : [{
          vpc_name = vpc_name
          zone_name = zone_name
          zone = "${var.region}-${local.zone_name_2_id[zone_name]}"
          subnet_name = subnet_name
          subnet = subnet
        }]
      ]
    ]
  ])
}

# A list of all expanded instance details from var.vpc_infrastructure

locals {

  instance_expansion = flatten([
    for vpc_name, vpc in var.vpc_infrastructure : [
      for zone_name, zone in vpc.zones : [
        for subnet_name, subnet in zone.subnets : [
          for instance_name, instance in subnet.instances : [{
            vpc_name = vpc_name
            zone_name = zone_name
            zone = "${var.region}-${local.zone_name_2_id[zone_name]}"
            subnet_name = subnet_name
            instance_name = instance_name
            tags = instance.tags
            type = instance.type
            instance = instance
          }]
        ]
      ]
    ]
  ])
}


# Load Balancer List which contains a list of load balancers to create

locals {
  
  load_balancers = flatten([
    for vpc_name, vpc in var.vpc_infrastructure : [
      for load_balancer_name in vpc.load_balancers : [{
        vpc_name = vpc_name
        name = load_balancer_name
        type = var.vpc_load_balancers[load_balancer_name].type
        logging = var.vpc_load_balancers[load_balancer_name].logging
        profile = var.vpc_load_balancers[load_balancer_name].profile
        tags = var.vpc_load_balancers[load_balancer_name].tags

        subnets = flatten([
          for subnet in local.subnet_expansion : [
            module.vpc-infrastructure[vpc_name].vpc_subnets["${subnet.zone_name}-${subnet.subnet_name}"].id
          ] if contains(subnet.subnet.load_balancers, load_balancer_name)
        ])

        security_groups = flatten([
          for security_group in var.vpc_load_balancers[load_balancer_name].security_groups : [
            module.vpc-security-groups[vpc_name].security_group_ids[security_group]
          ]
        ])
      }]
    ]
  ])
}

locals {
  
  load_balancers_details = flatten([
    for vpc_name, vpc in var.vpc_infrastructure : [
      for load_balancer_name in vpc.load_balancers : [{
        vpc_name = vpc_name
        name = load_balancer_name

        lb_pools = flatten([
          for listener in var.vpc_load_balancers[load_balancer_name].listeners : [
            for pool in listener.pools : [
              pool
            ]
          ]
        ])

        lb_pool_members = [flatten([
          for listener in var.vpc_load_balancers[load_balancer_name].listeners : [
            for pool in listener.pools : [
              for pool_member in pool.members : [
                for instance in local.instance_expansion : [{
                  lb_pool_name = pool.name
                  port = pool_member.port
                  target_id = pool_member.target_id
                  weight = pool_member.weight
                  target_address = module.vpc-instance["${vpc_name}-${instance.zone_name}-${instance.instance_name}"].primary_ip[0][0]
                  name = "${vpc_name}-${instance.zone_name}-${instance.instance_name}"
                }] if instance.vpc_name == vpc_name && instance.instance_name == pool_member.target_address
              ]
            ]
          ]
        ])]

        lb_listeners = flatten([
          for listener in var.vpc_load_balancers[load_balancer_name].listeners : [
            merge(listener, {default_pool = listener.pools[0].name})
          ]
        ])
      }]
    ]
  ])
}

# Instance Groups

locals {

  instance_groups = flatten([
    for vpc_name, vpc in var.vpc_infrastructure : [
      for instance_group in vpc.instance_groups : [
        {
          vpc_name = vpc_name
          name = instance_group
          instance_count = var.instance_groups[instance_group].instance_count
          load_balancer = var.instance_groups[instance_group].load_balancer
          load_balancer_pool = var.instance_groups[instance_group].load_balancer_pool
          application_port = var.instance_groups[instance_group].application_port
          group_manager = var.instance_groups[instance_group].group_manager

          instance_template = flatten([
            for instance in local.instance_expansion : [
              module.vpc-instance-template["${instance.vpc_name}-${instance.instance_name}"].instance_template_id
            ] if instance.instance_name == instance_group
          ])[0]

        subnets = flatten([
          for subnet in local.subnet_expansion : [
            module.vpc-infrastructure[vpc_name].vpc_subnets["${subnet.zone_name}-${subnet.subnet_name}"].id
          ] if contains(subnet.subnet.instance_groups, instance_group)
        ])

        }
      ]
    ]
  ])
}

# Bastion Floating Point IP Address

locals {

  bastion_ip = flatten([
    for instance in local.instance_expansion : [
      module.vpc-instance["${instance.vpc_name}-${instance.zone_name}-${instance.instance_name}"].floating_ip
    ] if instance.instance_name == "bastion"
  ])[0]
}

# Load Balancer Host Names

locals {

  lb_web = flatten([
    for load_balancer in local.load_balancers : [
      ibm_is_lb.lbs["${load_balancer.vpc_name}-${load_balancer.name}"].hostname
    ] if load_balancer.name == "load-balancer-front"
  ])[0]
}

locals {

  lb_app = flatten([
    for load_balancer in local.load_balancers : [
      ibm_is_lb.lbs["${load_balancer.vpc_name}-${load_balancer.name}"].hostname
    ] if load_balancer.name == "load-balancer-back"
  ])[0]
}

