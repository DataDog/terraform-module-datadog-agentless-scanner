terraform {
  required_version = ">= 1.0"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.72.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

resource "datadog_agentless_scanning_aws_scan_options" "scan_options" {
  for_each = var.aws_account_ids

  aws_account_id     = each.value
  vuln_host_os       = true
  vuln_containers_os = true
  lambda             = true
  sensitive_data     = false
}
