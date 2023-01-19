##############################################################
# Create Security Groups
##############################################################

resource "ibm_is_security_group" "security_groups" {

  for_each       = { for g in var.vpc_groups_to_create : g => g }
  name           = "${var.resources_prefix}-${var.vpc_name}-${each.key}"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

##############################################################
# Create Security Group Rules
##############################################################

locals {
  security_group_rules = flatten([
    for k in var.vpc_groups_to_create : [
        for r in var.vpc_security_groups[k] : {
          security_group_id = ibm_is_security_group.security_groups["${k}"].id
          security_group_rule = "${k}-${r.name}"
          name       = r.name
          direction  = r.direction
          remote     = lookup(r, "remote", null)
          remote_id  = lookup(r, "remote_id", null) == null ? null : ibm_is_security_group.security_groups["${r["remote_id"]}"].id
          ip_version = lookup(r, "ip_version", null)
          icmp       = lookup(r, "icmp", null)
          tcp        = lookup(r, "tcp", null)
          udp        = lookup(r, "udp", null)
        }
     ]
  ]) 
}

resource "ibm_is_security_group_rule" "security_group_rules" {
  for_each   = { for r in local.security_group_rules : r.security_group_rule => r }
  group      = each.value.security_group_id
  direction  = each.value.direction
  remote = each.value.remote_id == null ? each.value.remote : each.value.remote_id
  ip_version = each.value.ip_version != "" ? each.value.ip_version : "ipv4"
  dynamic "icmp" {
    for_each = lookup(each.value, "icmp") == null ? [] : [each.value.icmp]
    content {
      code = lookup(icmp.value, "code", null)
      type = lookup(icmp.value, "type", null)
    }
  }
  dynamic "tcp" {
    for_each = lookup(each.value, "tcp") == null ? [] : [each.value.tcp]
    content {
      port_min = lookup(tcp.value, "port_min", 1)
      port_max = lookup(tcp.value, "port_max", 65535)
    }
  }
  dynamic "udp" {
    for_each = lookup(each.value, "udp") == null ? [] : [each.value.udp]
    content {
      port_min = lookup(udp.value, "port_min", 1)
      port_max = lookup(udp.value, "port_max", 65535)
    }
  }
  depends_on = [
    ibm_is_security_group.security_groups
  ]
}