resource "ibm_is_instance_group" "instance_group" {
  name               = var.name
  instance_template  = var.instance_template
  instance_count     = var.instance_count
  subnets            = var.subnets
  load_balancer      = var.load_balancer
  load_balancer_pool = var.load_balancer_pool
  application_port   = var.application_port
  resource_group     = var.resource_group
}

resource "ibm_is_instance_group_manager" "instance_group_manager" {
  name                 = "${var.name}-manager"
  aggregation_window   = var.group_manager.aggregation_window
  instance_group       = ibm_is_instance_group.instance_group.id
  cooldown             = var.group_manager.cooldown
  manager_type         = var.group_manager.manager_type
  enable_manager       = var.group_manager.enable_manager
  max_membership_count = var.group_manager.max_membership_count
  min_membership_count = var.group_manager.min_membership_count
}

resource "ibm_is_instance_group_manager_policy" "instance_group_policy" {
  for_each               = { for policy in var.group_manager.policies : policy.name => policy }
  instance_group         = ibm_is_instance_group.instance_group.id
  instance_group_manager = ibm_is_instance_group_manager.instance_group_manager.manager_id
  metric_type            = each.value.metric_type
  metric_value           = each.value.metric_value
  policy_type            = each.value.policy_type
  name                   = "${var.name}-${each.value.name}-policy"
}

