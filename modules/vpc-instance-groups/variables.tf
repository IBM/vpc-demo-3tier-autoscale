#####################################################
# AU Parameters
# Copyright 2022 IBM
#####################################################

variable "resource_group" {
  description = "Resource group ID"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the Instance Group"
  type        = string
}

variable "instance_template" {
  description = "ID of the Instance Template"
  type        = string
}

variable "instance_count" {
  description = "Number of Instances to create in the Instance Group"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "List of subnet ID to create the Instance Group on"
  type        = list
}

variable "load_balancer" {
  description = "ID of the Load Balancer to attach the Instance Group to"
  type        = string
}

variable "load_balancer_pool" {
  description = "ID of the Load Balancer Pool to attach the Instance Group to"
  type        = string
}

variable "application_port" {
  description = "Port to forward traffic to, ie, the port the members are listening on"
  type        = string
}

variable "group_manager" {
  description = "Group Manager construct which is associated with the Instance Group"
  type = object({
    aggregation_window   = number
    cooldown             = number
    manager_type         = string
    enable_manager       = bool
    max_membership_count = number
    min_membership_count = number

    policies = list(object({
        metric_type  = string
        metric_value = number
        policy_type  = string
        name         = string

    }))
  })
}

