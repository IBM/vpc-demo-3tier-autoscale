
output "vpc_id" {

    description = "The ID of the VPC Created"
    value = ibm_is_vpc.vpc[0].id
}

output "vpc_name" {

    description = "Name of the VPC Created"
    value = ibm_is_vpc.vpc[0].name
}

output "vpc_subnets" {

    description = "Name, ID and zone of a given subnet/zone"
    value = {

        for k, v in ibm_is_subnet.subnets : k => {
            name = v.name
            id = v.id
            zone = v.zone
            cidr = v.ipv4_cidr_block
        }
    }
}






