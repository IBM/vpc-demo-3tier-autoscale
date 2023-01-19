variable "dashboards" {

    description = "Sysdig Dashboards  To Create"
    default = []
}

variable "sysdig_monitor_api_token" {

    description = "Sysdig API Key Token, sourced from Key_Credentials[apikey]"
    default = ""
}

variable "sysdig_monitor_url" {

    description = "Sysdig API Endpoint, eg us-south.monitoring.cloud.ibm.com"
    default = ""
}

variable "iam_access_token" {

    description = "IBM api session token sourced from data.ibm_iam_auth_token.tokendata.iam_access_token"
    default = ""
}

variable "logging_instance_id" {

    description = "Logging Instance guid"
    default = ""
}
