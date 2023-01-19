
variable "vpc_security_groups" {

  description = "Map of security groups and rules"
  default = {}
}

variable "vpc_groups_to_create" {

    description = "A list of Security Groups to create"
    type = list
    default = []
}

variable "resources_prefix" {
  type        = string
  default     = ""
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Demo Application. It is not possible to create multiple resources with same name. Make sure that the prefix is unique."
}

variable "resource_group_id" {
  description = "Resource group ID to create the Security Group Rules in"
  default = ""
  type = string

}

variable "vpc_id" {
    description = "ID of the VPC to create the security group in"
    type = string
    default = ""
}

variable "vpc_name" {
    description = "Name of the VPC to create the security group in"
    type = string
    default = ""
}