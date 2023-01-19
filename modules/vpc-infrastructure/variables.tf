
##############################################################
# Basic VPC Creation Variables
##############################################################

variable "create_vpc" {
  description = "True to create new VPC. False if VPC is already existing and subnets or address prefixies are to be added"
  type        = bool
}

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = null
}

variable "resources_prefix" {
  description = "Generated resources prefix"
  type        = string
  default     = null
}

variable "resource_group_id" {
  description = "ID of resource group."
  type        = string
  default     = null
}

variable "classic_access" {
  description = "Classic Access to the VPC"
  type        = bool
  default     = null
}

variable "default_address_prefix" {
  description = "Default address prefix creation method"
  type        = string
  default     = null
}

variable "default_network_acl_name" {
  description = "Name of the Default ACL"
  type        = string
  default     = null
}

variable "default_security_group_name" {
  description = "Name of the Default Security Group"
  type        = string
  default     = null
}

variable "default_routing_table_name" {
  description = "Name of the Default Routing Table"
  type        = string
  default     = null
}

variable "vpc_tags" {
  description = "List of Tags for the vpc"
  type        = list(string)
  default     = []
}

variable "region" {
  type        = string
  description = "Name of the IBM Cloud region where the resources need to be provisioned.(Examples: us-east, us-south, etc.) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

variable "security_groups" {
  type        = list
  description = "List of security groups to create for this vpc"
  default = []
}

##############################################################
# Zones
##############################################################

variable "zones" {
  description = "Map of zones in the vpc"
  default = {}
}
