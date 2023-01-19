#####################################################
# Instance Parameters
# Copyright 2020 IBM
#####################################################

variable "name" {
  description = "Name of the Instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "location" {
  description = "Instance zone"
  type        = string
}

variable "image_os" {
  description = "Image OS type for the instance"
  type        = string
}

variable "image_architecture" {
  description = "Image Architecture, eg, amd64"
  type        = string
}

variable "profile" {
  description = "Profile type for the Instance"
  type        = string
}

variable "ssh_keys" {
  description = "List of ssh key IDs the instance"
  type        = list(string)
}

variable "resources_prefix" {
  type        = string
  default     = ""
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Demo Application. It is not possible to create multiple resources with same name. Make sure that the prefix is unique."
}

variable "primary_network_interface" {
  description = "List of primary_network_interface that are to be attached to the instance"
  type = list(object({
    subnet               = string
    interface_name       = string
    security_groups      = list(string)
    primary_ipv4_address = string
  }))
}

variable "floating_ip" {
  type        = bool
  default     = false
  description = "Boolean to attach a floating IP to the instance"
}

variable "private_ssh_key" {
  type        = string
  default     = ""
  description = "Value of the private ssh key, empty string to not create."
}

variable "propegate_keys" {
  type        = bool
  default     = false
  description = "Boolean to determine whether to create a private key on this instance"
}

#####################################################
# Optional Parameters
#####################################################

variable "no_of_instances" {
  description = "number of Instances"
  type        = number
  default     = 1
}

variable "resource_group_id" {
  description = "Resource group ID"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User Data for the instance"
  type        = string
  default     = null
}

variable "data_volumes" {
  description = "List of volume ids that are to be attached to the instance"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "List of Tags for the Instance"
  type        = list(string)
  default     = []
}

variable "network_interfaces" {
  description = "List of network_interfaces that are to be attached to the instance"
  type = list(object({
    subnet               = string
    interface_name       = string
    security_groups      = list(string)
    primary_ipv4_address = string
  }))
  default = []
}

variable "boot_volume" {
  description = "List of boot volume that are to be attached to the instance"
  type = list(object({
    name       = string
    encryption = string
  }))
  default = []
}