#####################################################
# Sysdig monitor Key Instance
# Copyright 2020 IBM
#####################################################

variable "provision" {
  type        = bool
  description = "Disable this to read the existing activity trcaker instance"
  default     = true
}

variable "bind_key" {
  description = "Enable this to bind key to instance (true/false)"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "plan" {
  description = "plan type"
  type        = string
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

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in Sysdig"
  default     = true
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

variable "key_name" {
  description = "Name of the instance key"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "key_tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = null
}