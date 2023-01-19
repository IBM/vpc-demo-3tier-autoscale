#####################################################
# Activity Tracker as a service
# Copyright 2020 IBM
#####################################################

variable "provision" {
  type        = bool
  description = "Disable this to read the existing activity trcaker instance"
  default     = true
}

variable "is_ats_instance" {
  type        = bool
  description = "Set this to provison ATS instance"
  default     = true
}

variable "name" {
  type        = string
  description = "Enter The name of the activity tracker ATS instance"
}

variable "plan" {
  type        = string
  description = "The type of plan the service instance should run under (lite, 7-day, 14-day, or 30-day)"
}

variable "region" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "resource_group_id" {
  type        = string
  description = "ID of the Resource group where the cluster has been provisioned."
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}

variable "service_supertenant" {
  type        = string
  description = "Name of your supertenant service"
  default     = null
}

variable "associated_logging_crn" {
  type        = string
  description = "CRN associated logging logdna"
  default     = null
}

variable "provision_key" {
  type        = string
  description = "Provision key"
  default     = null
}

variable "make_default_receiver" {
  type        = bool
  description = "Enable this to make this instance as default receiver"
  default     = true
}

variable "tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = null
}

variable "bind_key" {
  description = "Enable this to bind key to instance (true/false)"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the instance key"
  type        = string
  default     = ""
}

variable "key_tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = null
}