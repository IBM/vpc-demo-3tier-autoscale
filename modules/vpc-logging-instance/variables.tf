#####################################################
# Logging-logdna  Instance
# Copyright 2020 IBM
#####################################################

variable "provision" {
  type        = bool
  description = "Disable this to read the existing activity trcaker instance"
  default     = true
}

variable "is_sts_instance" {
  description = "Set this to provision (STS) logging instance"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "enable_platform_logs" {
  type        = bool
  description = "Receive platform logs in LogDNA"
  default     = true
}


variable "plan" {
  description = "plan type"
  type        = string
}

variable "service_supertenant" {
  type        = string
  description = "Name of your supertenant service"
  default     = null
}

variable "provision_key" {
  type        = string
  description = "Provision key"
  default     = null
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

variable "region" {
  description = "Provisioning Region"
  type        = string
}

variable "service_endpoints" {
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
  type        = string
  default     = null
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

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}