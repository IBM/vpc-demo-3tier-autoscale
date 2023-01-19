##############################################################
# Create VPC Infrastructure
# - VPC
# - Address Prefixes
# - Subnets
# - Security Groups
##############################################################

module "vpc-infrastructure" {
  source = "./modules/vpc-infrastructure"
  for_each = var.vpc_infrastructure
  
  create_vpc = true
  region = var.region
  resources_prefix = local.resources_prefix
  vpc_name = each.value.name
  resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  default_address_prefix = each.value.address_prefix_management
  vpc_tags = each.value.tags
  zones = each.value.zones
  security_groups = each.value["security_groups"]
}

##############################################################
# Create Security Groups and Rules
##############################################################

module "vpc-security-groups" {

  source = "./modules/vpc-security-groups"
  for_each = var.vpc_infrastructure
    vpc_security_groups = var.vpc_security_groups
    vpc_groups_to_create = each.value.security_groups
    resources_prefix = local.resources_prefix
    resource_group_id = data.ibm_resource_group.resource_group_vpc.id
    vpc_id = module.vpc-infrastructure[each.value.name].vpc_id
    vpc_name = each.value.name
}

##############################################################
# Deploy Monitoring
##############################################################

# Provision sysdig logging instance if required

module "vpc-monitoring-instance" {

  source            = "./modules/vpc-monitoring-instance"
  provision         = var.create_monitoring_instance
  bind_key          = true
  name              = var.create_monitoring_instance ? "${local.resources_prefix}-monitoring" : var.vpc_monitoring_instance
  resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  plan              = "lite"
  region            = var.region
  enable_platform_metrics = false
  tags              = []
  key_name = "${local.resources_prefix}-monitoring-key"
  key_tags = []
}

##############################################################
# Deploy logging
##############################################################

# Provision logdna logging instance if required

module "vpc-logging-instance" {

  source            = "./modules/vpc-logging-instance"
  provision         = var.create_logging_instance
  is_sts_instance   = false
  bind_key          = true
  name              = var.create_logging_instance ? "${local.resources_prefix}-logging" : var.vpc_logging_instance
  resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  plan              = var.logging_instance_plan
  region            = var.region
  enable_platform_logs = false
  tags              = []
  key_name = "${local.resources_prefix}-logging-key"
  key_tags = []
}

##############################################################
# Deploy Monitoring Dashboard
##############################################################

data "ibm_iam_auth_token" "tokendata" {}

module "vpc-logging-dashboard" {

  source = "./modules/vpc-monitoring-dashboard"

  dashboards = jsondecode(file(var.monitoring_instance_file))
  sysdig_monitor_api_token = module.vpc-monitoring-instance.key_credentials["apikey"]
  sysdig_monitor_url = "https://${var.region}.monitoring.cloud.ibm.com"
  iam_access_token = data.ibm_iam_auth_token.tokendata.iam_access_token
  logging_instance_id = module.vpc-monitoring-instance.guid

}

##############################################################
# Deploy Activity Tracker instance
# 
# We will set the following for a single ATR Instance.
#`activity_tracker_provision` = true
#`is_ats_instance` = false
#`activity_tracker_service_supertenant` = null
#`activity_tracker_provision_key` = null
#`service_supertenant` = null
#`provision_key` = null
##############################################################

module "activity_tracker_instance" {

  source                 = "./modules/vpc-activity-tracker"

  provision              = var.create_activity_tracker
  is_ats_instance        = false
  name                   = "${local.resources_prefix}-activity-tracker"
  plan                   = var.logging_instance_plan
  region                 = var.region
  bind_key               = false
  resource_group_id      = data.ibm_resource_group.resource_group_vpc.id
}

##############################################################
# Deploy Application Database
##############################################################

resource "ibm_database" "postgresql" {
  name              = "${local.resources_prefix}-${var.database_name}"
  resource_group_id = data.ibm_resource_group.resource_group_vpc.id
  plan              = "standard"
  service           = "databases-for-postgresql"
  location          = var.region
}

resource "ibm_resource_key" "postgresql" {
  name                 = "${local.resources_prefix}-${var.database_name}"
  resource_instance_id = ibm_database.postgresql.id
  role = "Administrator"
  depends_on = [
    ibm_database.postgresql
  ]
}

##############################################################
# Create Instances
##############################################################

# Define Instance User Data
# each instance type has a user_data file as well as associated variables

locals {

  instance_configuration = {
    bastion = {
      ansible_variables = {}
    }
    web = {
      ansible_variables = {
        logdna_key = module.vpc-logging-instance.key_credentials["ingestion_key"]
        logdna_logdir = ["/tmp", "/root"]
        logdna_apihost = "api.${var.region}.logging.cloud.ibm.com"
        logdna_loghost = "logs.private.${var.region}.logging.cloud.ibm.com"
        logdna_tags = [
          for instance in local.instance_expansion : [
            instance.tags
          ] if instance.instance_name == "web"
        ][0][0]
        sysdig_key = module.vpc-monitoring-instance.key_credentials["Sysdig Access Key"]
        sysdig_endpoint = "ingest.private.${var.region}.monitoring.cloud.ibm.com"
        sysdig_port = "6443"
        sysdig_tags = join(",",[
          for instance in local.instance_expansion : [
            instance.tags
          ] if instance.instance_name == "web"
        ][0][0])
        demo_role = "front"
        demo_lb_back = flatten([for load_balancer in local.load_balancers : [
                                  ibm_is_lb.lbs["${load_balancer.vpc_name}-${load_balancer.name}"].hostname
                                ] if load_balancer.name == "load-balancer-back"
                       ])[0]
      }
    }
    app = {
      ansible_variables = {
        logdna_key = module.vpc-logging-instance.key_credentials["ingestion_key"]
        logdna_logdir = ["/tmp", "/root"]
        logdna_apihost = "api.${var.region}.logging.cloud.ibm.com"
        logdna_loghost = "logs.private.${var.region}.logging.cloud.ibm.com"
        logdna_tags = [
          for instance in local.instance_expansion : [
            instance.tags
          ] if instance.instance_name == "app"
        ][0][0]
        sysdig_key = module.vpc-monitoring-instance.key_credentials["Sysdig Access Key"]
        sysdig_endpoint = "ingest.private.${var.region}.monitoring.cloud.ibm.com"
        sysdig_port = "6443"
        sysdig_tags = join(",",[
          for instance in local.instance_expansion : [
            instance.tags
          ] if instance.instance_name == "app"
        ][0][0])
        demo_role = "back"
        demo_lb_back = flatten([for load_balancer in local.load_balancers : [
                                  ibm_is_lb.lbs["${load_balancer.vpc_name}-${load_balancer.name}"].hostname
                                ] if load_balancer.name == "load-balancer-back"
                       ])[0]
      }
    }
  }
}

# Deploy Instances

module "vpc-instance" {

  source = "./modules/vpc-instance"
  for_each = { for i in local.instance_expansion : "${i.vpc_name}-${i.zone_name}-${i.instance_name}" => i if i.type == "instance"}
    name = "${local.resources_prefix}-${each.value.vpc_name}-${each.value.zone}-${each.value.instance_name}"
    vpc_id = module.vpc-infrastructure[each.value.vpc_name].vpc_id
    location = each.value.zone
    image_os = var.vpc_instance_types[each.value.instance.vpc_instance_type].image_os
    image_architecture = var.vpc_instance_types[each.value.instance.vpc_instance_type].image_architecture
    profile = var.vpc_instance_types[each.value.instance.vpc_instance_type].profile
    ssh_keys = local.ssh_keys[var.vpc_instance_types[each.value.instance.vpc_instance_type].os_family]
    resource_group_id = data.ibm_resource_group.resource_group_vpc.id
    resources_prefix = local.resources_prefix
    floating_ip = each.value.instance.floating_ip
    private_ssh_key = tls_private_key.instance_rsa.private_key_pem
    propegate_keys = each.value.instance.propegate_keys
    tags = each.value.tags
    primary_network_interface = [{
      primary_ipv4_address = ""
      interface_name = ""
      subnet = module.vpc-infrastructure[each.value.vpc_name].vpc_subnets["${each.value.zone_name}-${each.value.subnet_name}"].id
      security_groups = flatten([
        for security_group in each.value.instance.security_groups : [
          module.vpc-security-groups[each.value.vpc_name].security_group_ids[security_group]
        ]
      ])
    }]
    user_data = templatefile("./user-data/${each.value.instance_name}-linux.tpl", {
                  ansible_variables = jsonencode(local.instance_configuration[each.value.instance_name].ansible_variables)
                  ansible_roles = each.value.instance.roles
                  ansible_namespace = var.ansible_namespace
                  ansible_collection = var.ansible_collection
                  ansible_url = var.ansible_url
                  service_credentials = jsonencode(nonsensitive(ibm_resource_key.postgresql.credentials))}
                  )
  depends_on = [
    ibm_resource_key.postgresql,
    ibm_is_lb.lbs
  ]
}

##############################################################
# Create Instance Templates
##############################################################

module "vpc-instance-template" {

  source = "./modules/vpc-instance-template"
  for_each = { for i in local.instance_expansion : "${i.vpc_name}-${i.instance_name}" => i if i.type == "instance_template"}
    name = "${local.resources_prefix}-${each.value.vpc_name}-${each.value.zone}-${each.value.instance_name}"
    vpc_id = module.vpc-infrastructure[each.value.vpc_name].vpc_id
    location = each.value.zone
    image_os = var.vpc_instance_types[each.value.instance.vpc_instance_type].image_os
    image_architecture = var.vpc_instance_types[each.value.instance.vpc_instance_type].image_architecture
    profile = var.vpc_instance_types[each.value.instance.vpc_instance_type].profile
    ssh_keys = local.ssh_keys[var.vpc_instance_types[each.value.instance.vpc_instance_type].os_family]
    resource_group_id = data.ibm_resource_group.resource_group_vpc.id
    resources_prefix = local.resources_prefix
    floating_ip = each.value.instance.floating_ip
    private_ssh_key = tls_private_key.instance_rsa.private_key_pem
    propegate_keys = each.value.instance.propegate_keys
    primary_network_interface = [{
      primary_ipv4_address = ""
      interface_name = ""
      subnet = module.vpc-infrastructure[each.value.vpc_name].vpc_subnets["${each.value.zone_name}-${each.value.subnet_name}"].id
      security_groups = flatten([
        for security_group in each.value.instance.security_groups : [
          module.vpc-security-groups[each.value.vpc_name].security_group_ids[security_group]
        ]
      ])
    }]
    user_data = templatefile("./user-data/${each.value.instance_name}-linux.tpl", {
                  ansible_variables = jsonencode(local.instance_configuration[each.value.instance_name].ansible_variables)
                  ansible_roles = each.value.instance.roles
                  ansible_namespace = var.ansible_namespace
                  ansible_collection = var.ansible_collection
                  ansible_url = var.ansible_url
                  service_credentials = jsonencode(nonsensitive(ibm_resource_key.postgresql.credentials))}
                  )
  depends_on = [
    ibm_resource_key.postgresql,
    ibm_is_lb.lbs
  ]
}

##############################################################
# Create Load Balancers
##############################################################

# This is kind of a horrible thing to do but we have a circular dependency
# We need to create the load balancer before the instance, however, we also
# need the instances created before we populate the member pools.

resource "ibm_is_lb" "lbs" {

  for_each = { for l in local.load_balancers : "${l.vpc_name}-${l.name}" => l }

  name            = "${local.resources_prefix}-${each.value.vpc_name}-${each.value.name}"
  subnets         = each.value.subnets
  type            = each.value.type
  security_groups = each.value.security_groups
  profile         = each.value.profile
  logging         = each.value.logging
  resource_group  = data.ibm_resource_group.resource_group_vpc.id
  tags            = each.value.tags
}

# Populate pools and members (After instance creation)

module "vpc-load-balancer" {

  source = "./modules/vpc-load-balancer"
  for_each = { for l in local.load_balancers_details : "${l.vpc_name}-${l.name}" => l }

  create_load_balancer = false
  name = "${local.resources_prefix}-${each.value.vpc_name}-${each.value.name}"
  lb_pools = each.value.lb_pools
  lb_pool_members = []
  lb_listeners = each.value.lb_listeners
  lb_listener_policies = []
  lb_listener_policy_rules = []

 depends_on = [
    ibm_is_lb.lbs
  ]

}

##############################################################
# Create Instance Groups
##############################################################

module "vpc-instance-groups" {

  source = "./modules/vpc-instance-groups"
  for_each = { for instance_group in local.instance_groups : "${instance_group.vpc_name}-${instance_group.name}" => instance_group }

  resource_group = data.ibm_resource_group.resource_group_vpc.id
  name = "${local.resources_prefix}-${each.value.vpc_name}-${each.value.name}"
  instance_template = each.value.instance_template
  instance_count = each.value.instance_count
  subnets = each.value.subnets
  load_balancer = ibm_is_lb.lbs["${each.value.vpc_name}-${each.value.load_balancer}"].id
  load_balancer_pool = module.vpc-load-balancer["${each.value.vpc_name}-${each.value.load_balancer}"].lb_pool_id_map[each.value.load_balancer_pool]
  application_port = each.value.application_port
  group_manager = each.value.group_manager

 depends_on = [
    ibm_is_lb.lbs,
    module.vpc-load-balancer,
    module.vpc-instance-template

  ]
}

output "poolidmap" {
  value = module.vpc-load-balancer["demo-vpc-load-balancer-back"].lb_pool_id_map
}

