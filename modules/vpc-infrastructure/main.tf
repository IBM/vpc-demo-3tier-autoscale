#####################################################
# Create VPC
#####################################################

resource "ibm_is_vpc" "vpc" {
  count                       = var.create_vpc ? 1 : 0
  name                        = "${var.resources_prefix}-${var.vpc_name}"
  resource_group              = var.resource_group_id
  classic_access              = (var.classic_access != null ? var.classic_access : false)
  address_prefix_management   = (var.default_address_prefix != null ? var.default_address_prefix : "auto")
  default_network_acl_name    = (var.default_network_acl_name != null ? var.default_network_acl_name : null)
  default_security_group_name = (var.default_security_group_name != null ? var.default_security_group_name : null)
  default_routing_table_name  = (var.default_routing_table_name != null ? var.default_routing_table_name : null)
  tags                        = (var.vpc_tags != null ? var.vpc_tags : [])
}

#####################################################
# Create Address Prefixes for each Zone
#####################################################

resource "ibm_is_vpc_address_prefix" "vpc_address_prefixes" {
  for_each = var.zones
  name     = each.key
  vpc      = ibm_is_vpc.vpc[0].id
  zone     = "${var.region}-${local.zone_to_id[each.key]}"
  cidr     = each.value["address_prefix"]
}

#####################################################
# Create Public Gateway
#####################################################

resource "ibm_is_public_gateway" "public_gateway" {
  for_each = var.zones
  name           = "${var.resources_prefix}-${each.key}-gateway"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.vpc[0].id
  zone           = "${var.region}-${local.zone_to_id[each.key]}"
}

#####################################################
# Create Subnets
#####################################################

resource "ibm_is_subnet" "subnets" {
  for_each = { for subnet in local.subnet_map : "${subnet.zone}-${subnet.subnet_type}" => subnet }

  name = "${var.resources_prefix}-${each.key}"
  resource_group = var.resource_group_id
  vpc = ibm_is_vpc.vpc[0].id
  zone = "${var.region}-${local.zone_to_id[each.value["zone"]]}"
  ipv4_cidr_block = cidrsubnet(each.value["address_prefix"], each.value["subnet_size"], each.value["cidr_offset"])
  public_gateway = each.value["public_gateway"] ? ibm_is_public_gateway.public_gateway[each.value["zone"]].id : null
  tags = (each.value["tags"] != null ? each.value["tags"] : [])

  depends_on = [
    ibm_is_vpc_address_prefix.vpc_address_prefixes,
    ibm_is_public_gateway.public_gateway
  ]

}
