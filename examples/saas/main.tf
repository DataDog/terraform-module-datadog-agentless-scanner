terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 4.16.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

module "agentless_scanning_policy" {
  // TODO: switch to the git source pinned to the release shipping this module.
  source = "../../modules/agentless-scanning-policy"

  role_name = var.datadog_integration_role
}

resource "datadog_agentless_scanning_aws_scan_options" "scan_options" {
  aws_account_id     = data.aws_caller_identity.current.account_id
  vuln_host_os       = true
  vuln_containers_os = true
  lambda             = true
  sensitive_data     = true
  compliance_host    = true

  depends_on = [module.agentless_scanning_policy]
}
