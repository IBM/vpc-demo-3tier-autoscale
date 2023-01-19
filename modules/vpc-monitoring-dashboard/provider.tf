terraform {
  required_providers {
    sysdig = {
      source = "sysdiglabs/sysdig"
      version = "0.5.40"
    }
  }
}

provider "sysdig" {
  sysdig_monitor_api_token = var.sysdig_monitor_api_token
  sysdig_monitor_url = var.sysdig_monitor_url
    extra_headers = {
    "Authorization" = var.iam_access_token
    "IBMInstanceID" = var.logging_instance_id
  }
}
