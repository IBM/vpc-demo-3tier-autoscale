##############################################################
# Provider and commmon IBM Cloud variables
##############################################################

### IBM Cloud API Key

variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key"
  type = string
}

### Resource group name

variable "resource_group_name" {
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed. For more information, see[Managing resource groups](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)."
  default = "rg"
  type = string
}

### Resources Prefix

variable "resource_prefix" {
  type        = string
  default     = ""
    validation {
       condition = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_prefix))
       error_message = "Please enter a string which starts with a character, no underscores allowed."
    }
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Demo Application. It is not possible to create multiple resources with same name. Make sure that the prefix is unique."
}

### Cloud Region

variable "region" {
  type        = string
  default     = ""
  description = "Name of the IBM Cloud region where the resources need to be provisioned.(Examples: us-east, us-south, etc.) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

#### IAM ####

variable "deploy_iam" {
  description = "Boolean to enable IAM deployment."
  default = false
  type = bool
}

#### SSH Key for all Instances ####

variable "ssh_key_name" {
  description = "Name of an existing ssh key for all instances created, leave blank if no instances are to be created"
  default     = ""
  type = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.ssh_key_name))
    error_message = "Invalid Key name, Use lowercase alphanumeric characters and hyphens only (without spaces)."
  }
  validation {
    condition     = can(regex("^[a-z]", var.ssh_key_name))
    error_message = "Invalid Key name, Enter a lowercase letter for the first character."
  }
}

#### Secrets Manager ####

variable "enable_secrets_manager" {
  description = "Enable secrets manager for secrets"
  type = bool
  default = true
}

variable "vpc_secrets_instance_id" {
  description = "Secrets manager instance if if enable_secrets_manager is set to true. Hint - a4a7e8bb-efdf-4cd0-b1a0-adbb5c5dd127 "
  type = string
  default = ""
}

#### Postgress Database ####

variable "database_name" {
  description = "Name of the postgress database"
  default     = "demo-database"
  type = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.database_name))
    error_message = "Invalid database name, Use lowercase alphanumeric characters and hyphens only (without spaces)."
  }
}

#######################################################################################################
# VPC Infrastructure Variables
# notices:
#    - For autoscaling, only a single instance template is required across all zones, please
#      use the subnet scoped instance_groups variable to define which subnets apply to an
#      instance group, these should be the same subnets as the Load Balancer attached to the instance group.
#######################################################################################################

variable "vpc_infrastructure" {
  description = "VPC infrastructure"
  type        = map
  default = {
    demo-vpc = {
      create_vpc = true
      name = "demo-vpc"
      address_prefix_management = "manual"
      tags = ["default_vpc"]
      security_groups = ["load-balancer-front", "load-balancer-back", "web-tier", "app-tier", "bastion"]
      load_balancers = ["load-balancer-front", "load-balancer-back"]
      instance_groups = ["web", "app"]
      zones = {
        zone1 = {
            address_prefix = "10.10.0.0/18"
            create_public_gateway = true
            subnets = {
              bastion-subnet = {
                cidr_offset = 3
                subnet_size = 4
                public_gateway = true
                load_balancers = []
                instance_groups = []
                tags = ["bastion"]
                instances = {
                  bastion = {
                    type = "instance"
                    vpc_instance_type = "app-instance-linux"
                    security_groups = ["bastion"]
                    floating_ip = true
                    propegate_keys = true
                    tags = ["bastion"]
                    roles = []
                  }
                }
              },
              web-subnet = {
                cidr_offset = 1
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-front"]
                instance_groups = ["web"]
                tags = ["web"]
                instances = {
                  web = {
                    type = "instance_template"
                    vpc_instance_type = "app-instance-linux"
                    security_groups = ["web-tier"]
                    floating_ip = false
                    propegate_keys = false
                    tags = ["web"]
                    roles = ["logdna", "sysdig", "demo"]
                  }
                }
              }
              app-subnet = {
                cidr_offset = 2
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-back"]
                instance_groups = ["app"]
                tags = ["app"]
                instances = {
                  app = {
                    type = "instance_template"
                    vpc_instance_type = "app-instance-linux"
                    security_groups = ["app-tier"]
                    floating_ip = false
                    propegate_keys = false
                    tags = ["app"]
                    roles = ["logdna", "sysdig", "demo"]
                  }
                }
              }
            }
        }
        zone2 = {
            address_prefix = "10.20.0.0/18"
            create_public_gateway = true
            subnets = {
              web-subnet = {
                tags = ["web"]
                cidr_offset = 1
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-front"]
                instance_groups = ["web"]
                instances = {}
              }
              app-subnet = {
                tags = ["app"]
                cidr_offset = 2
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-back"]
                instance_groups = ["app"]
                instances = {}
              }
            }
        }
        zone3 = {
            address_prefix = "10.30.0.0/18"
            create_public_gateway = true
            subnets = {
              web-subnet = {
                tags = ["web"]
                cidr_offset = 1
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-front"]
                instance_groups = ["web"]
                instances = {}
              }
              app-subnet = {
                tags = ["app"]
                cidr_offset = 2
                subnet_size = 4
                public_gateway = true
                load_balancers = ["load-balancer-back"]
                instance_groups = ["app"]
                instances = {}
              }
            }
        }
      }
    }
  }
}

##############################################################
# Instance Types
##############################################################

variable "vpc_instance_types" {

  description = "List of instance types"
  default = {
    app-instance-linux = {
      tags = []
      image_architecture = "amd64"
      os_family = "linux"
      image_os = "ubuntu-18-04-amd64"
      profile = "bx2-2x8"
    }
  }
}

##############################################################
# VPC Security Groups and Rules
##############################################################

variable "vpc_security_groups" {

  description = "Map of security groups and rules"
  default = {
    load-balancer-front = [
      {
        name      = "allow-inbound-80"
        direction = "inbound"
        remote    = "0.0.0.0/0"
        tcp = {
            port_max = 80
            port_min = 80
        }
      },
      {
        name      = "allow-outbound-8000"
        direction = "outbound"
        remote_id = "web-tier"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      }
    ],
    load-balancer-back = [
      {
        name      = "allow-inbound-8000"
        direction = "inbound"
        remote_id = "web-tier"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      },
      {
        name      = "allow-outbound-8000"
        direction = "outbound"
        remote_id = "app-tier"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      }
    ],
    web-tier = [
      {
        name      = "allow-inbound-8000"
        direction = "inbound"
        remote_id = "load-balancer-front"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      },
      {
        name      = "allow-outbound-8000"
        direction = "outbound"
        remote_id = "load-balancer-back"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      },
      {
        name      = "allow-bastion-22"
        direction = "inbound"
        remote_id    = "bastion"
        tcp = {
            port_max = 22
            port_min = 22
        }
      },
      {
        name      = "allow-web-2-public"
        direction = "outbound"
        remote    = "0.0.0.0/0"
        tcp = {
            port_max = 65535
            port_min = 1
        }
      },
      {
        name      = "allow-web-cse"
        direction = "outbound"
        remote    = "166.8.0.0/14"
        tcp = {
            port_max = 65535
            port_min = 1
        }
      }
    ],
    app-tier = [
      {
        name      = "allow-inbound-8000"
        direction = "inbound"
        remote_id = "load-balancer-back"
        tcp = {
            port_max = 8000
            port_min = 8000
        }
      },
      {
        name      = "allow-bastion-22"
        direction = "inbound"
        remote_id    = "bastion"
        tcp = {
            port_max = 22
            port_min = 22
        }
      },
      {
        name      = "allow-app-public"
        direction = "outbound"
        remote    = "0.0.0.0/0"
        tcp = {
            port_max = 65535
            port_min = 1
        }
      },
      {
        name      = "allow-app-cse"
        direction = "outbound"
        remote    = "166.8.0.0/14"
        tcp = {
            port_max = 65535
            port_min = 1
        }
      }
    ],
    bastion = [
      {
        name      = "allow-bastion-22"
        direction = "inbound"
        remote    = "0.0.0.0/0"
        tcp = {
            port_max = 22
            port_min = 22
        }
      },
      {
        name      = "allow-bastion-public"
        direction = "outbound"
        remote    = "0.0.0.0/0"
        tcp = {
            port_max = 65535
            port_min = 1
        }
      },
      {
        name      = "allow-bastion-web-tier-22"
        direction = "outbound"
        remote_id    = "web-tier"
        tcp = {
            port_max = 22
            port_min = 22
        }
      },
      {
        name      = "allow-bastion-app-tier-22"
        direction = "outbound"
        remote_id    = "app-tier"
        tcp = {
            port_max = 22
            port_min = 22
        }
      }
    ]
  }
}

##############################################################
# Load Balancers
##############################################################

variable vpc_load_balancers {

  description = "VPC Load Balancers"
  type = map
  default = {

    load-balancer-front = {
      type = "public"
      security_groups = ["load-balancer-front"]
      logging = false
      profile = null
      tags = ["web"]

      listeners = [
        {
          port = 80
          protocol = "http"
          certificate_instance = null
          connection_limit = null
          accept_proxy_protocol = false
          pools = [
            {
              name = "web-pool"
              algorithm = "round_robin"
              protocol = "http"
              health_delay = 15
              health_retries = 2
              health_timeout = 5
              health_type = "http"
              health_monitor_url = "/health"
              health_monitor_port = 8000
              session_persistence_type = null
              session_persistence_app_cookie_name = null
              members = []
            }
          ]
        }
      ]
    },
    load-balancer-back = {
      type = "private"
      security_groups = ["load-balancer-back"]
      logging = false
      profile = null
      tags = ["app"]

      listeners = [
        {
          port = 8000
          protocol = "http"
          certificate_instance = null
          connection_limit = null
          accept_proxy_protocol = false
          pools = [
            {
              name = "app-pool"
              algorithm = "round_robin"
              protocol = "http"
              health_delay = 15
              health_retries = 2
              health_timeout = 5
              health_type = "http"
              health_monitor_url = "/health"
              health_monitor_port = 8000
              session_persistence_type = null
              session_persistence_app_cookie_name = null
              members = []
            }
          ]
        }
      ]
    }
  }
}

###########################################################################
# Instance Groups
#   - Only relevant for Auto-Scaling where instance types are set to instance_templates
#   - The vpc_infrastructure->vpc->instance_groups[] must contain a reference
#   - A instance_template must have the same name as this Instance Group
###########################################################################

variable "instance_groups" {

    description = "Instance groups to attach to a Load Balancer for autoscaling."

    default = {

      web = {
        instance_count = 4
        load_balancer = "load-balancer-front"
        load_balancer_pool = "web-pool"
        application_port = 8000
        group_manager = {
          aggregation_window = 90
          cooldown = 240
          manager_type = "autoscale"
          enable_manager = true
          min_membership_count = 4
          max_membership_count = 18
          policies = [
            {
              name = "cpu"
              metric_type = "cpu"
              metric_value = 25
              policy_type = "target"
            }
          ]
        }
      }
      app = {
        instance_count = 2
        load_balancer = "load-balancer-back"
        load_balancer_pool = "app-pool"
        application_port = 8000
        group_manager = {
          aggregation_window = 90
          cooldown = 240
          manager_type = "autoscale"
          enable_manager = true
          min_membership_count = 2
          max_membership_count = 18
          policies = [
            {
              name = "cpu"
              metric_type = "cpu"
              metric_value = 25
              policy_type = "target"
            }
          ]
        }
      }
    }
}

##############################################################
# Logging and Monitoring
#   - Will be applied to all provisioned instances if enabled
##############################################################

variable "vpc_logging_instance" {
  description = "Name of existing logging instance, only relevant if create_logging_instance = false"
  type = string
  default = ""
}

variable "create_logging_instance" {
  description = "Boolean to determine whether to create a new logging instance."
  type = bool
  default = true
}

variable "logging_instance_plan" {
  description = "Boolean to determine whether to create a new logging instance.(eg, lite, 7-day)"
  type = string
  default = "lite"
}

variable "vpc_monitoring_instance" {
  description = "Name of existing logging instance, only relevant if create_monitoring_instance = false"
  type = string
  default = ""
}

variable "create_monitoring_instance" {
  description = "Boolean to determine whether to create a new monitoring instance."
  type = bool
  default = true
}

variable "monitoring_instance_file" {
  description = "File describing the dashboard to create."
  type = string
  default = "templates/sysdig-dashboard-demo.json"
}

variable "create_activity_tracker" {
  description = "Boolean to determine whether to create a new Activity Tracker"
  type = bool
  default = true
}

##############################################################
# Sysdig Dashboard
##############################################################

variable "dashboards" {

    description = "Sysdig Dashboard To Create"
    
    default = [
      {
        name = "3 Tier Application Monitoring"
        description = "3 Tier Application Monitoring"
        scope = [
          {
            metric = "host.hostName"
            variable = "hostname"
          }
        ]
        panel = [
          {
            pos_x       = 0
            pos_y       = 0
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "Web - CPU"
            description = "Web Layer CPU Utilization"
            query = [
              {
                promql = "topk(10,avg(avg_over_time(sysdig_host_cpu_used_percent{$__scope,agent_tag_Tag=~\"web\"}[$__interval])) by (host_hostname))"
                unit   = "percent"
              }
            ]
          },
          {
            pos_x       = 8
            pos_y       = 0
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "Web - request/second"
            description = "Web Layer http requests per second"
            query = [
              {
                promql = "sum(sum_over_time(sysdig_host_net_http_request_count{$__scope,agent_tag_Tag=~\"web\"}[$__interval]) / $__interval_sec)"
                unit   = "number rate"
              }
            ]
          },
          {
            pos_x       = 16
            pos_y       = 0
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "Web - response time"
            description = "Web Layer http response time"
            query = [
              {
                promql = "topk(10,avg(avg_over_time(sysdig_host_net_http_request_time{$__scope,agent_tag_Tag=~\"web\"}[$__interval])) by (host_hostname))"
                unit   = "time"
              }
            ]
          },
          {
            pos_x       = 0
            pos_y       = 6
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "App - CPU"
            description = "Application Layer CPU Utilization"
            query = [
              {
                promql = "topk(10,avg(avg_over_time(sysdig_host_cpu_used_percent{$__scope,agent_tag_Tag=~\"app\"}[$__interval])) by (host_hostname))"
                unit   = "percent"
              }
            ]
          },
          {
            pos_x       = 8
            pos_y       = 6
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "App - request/second"
            description = "Application Layer http requests per second"
            query = [
              {
                promql = "sum(sum_over_time(sysdig_host_net_http_request_count{$__scope,agent_tag_Tag=~\"app\"}[$__interval]) / $__interval_sec)"
                unit   = "number rate"
              }
            ]
          },
          {
            pos_x       = 16
            pos_y       = 6
            width       = 8 # Maximum size: 24
            height      = 6
            type        = "timechart" # timechart or number
            name        = "App - response time"
            description = "Application Layer http response time"
            query = [
              {
                promql = "topk(10,avg(avg_over_time(sysdig_host_net_http_request_time{$__scope,agent_tag_Tag=~\"app\"}[$__interval])) by (host_hostname))"
                unit   = "time"
              }
            ]
          }
        ]
      }
    ]
}

##############################################################
# Ansible
##############################################################

variable "ansible_url" {
  description = "Ansible GIT Repo URL"
  default = "https://github.com/ChristopherMoss/demo-ansible"
}

variable "ansible_namespace" {
  description = "Name of the Ansible Namespace for IBM Provided collections"
  default = "ibm"
}

variable "ansible_collection" {
  description = "Name of the Ansible Collection for IBM Provided collections"
  default = "demo"
}
