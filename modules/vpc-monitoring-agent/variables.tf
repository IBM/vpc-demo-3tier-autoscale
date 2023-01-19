
variable "os_family" {
  description = "Type of instance, either windows or linux"
  type        = string
  default     = "linux"
}

variable "region" {
  description = "Region where the logging instance resides"
  type        = string
  default     = "us-south"
}

variable "monitoring_key" {
  description = "Key of the logging instance."
  type        = string
  default     = ""
}

variable "monitoring_tags" {
  description = "A list of tags for the monitoring instance."
  type        = list
  default     = []
}

variable "instance_connection" {
  description = "Connection object to connect to instances for remote-exec"
  type        = object({
                  type = string
                  user = string
                  private_key = string
                  bastion_host = string
                  bastion_private_key = string
                  host = string
                })
  default     = {
                  type = ""
                  user = ""
                  private_key = ""
                  bastion_host = ""
                  bastion_private_key = ""
                  host = ""
  }
}
