#####################################################
# Helper to map zone id to a number, this in effect
# Limits the zone names to the values below
#####################################################

locals {
    zone_to_id = {
        zone1 = "1"
        zone2 = "2"
        zone3 = "3"
    }
}

#####################################################
# Create a list of all subnets
#####################################################

locals {

  subnet_map = flatten([
    for zone_name, zone in var.zones : [
      for subnet_type, subnet in zone.subnets : [
        {
          zone = zone_name
          subnet_type = subnet_type
          cidr_offset = subnet.cidr_offset
          subnet_size = subnet.subnet_size
          public_gateway = subnet.public_gateway
          address_prefix = var.zones[zone_name].address_prefix
          tags = subnet.tags
        }
      ]
    ]
  ])
}