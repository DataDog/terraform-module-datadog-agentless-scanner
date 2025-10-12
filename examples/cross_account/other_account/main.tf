terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.72.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.11"

  scanner_roles = [var.scanner_role_arn]
}

resource "datadog_agentless_scanning_aws_scan_options" "scan_options" {
  aws_account_id     = data.aws_caller_identity.current.account_id
  vuln_host_os       = true
  vuln_containers_os = true
  lambda             = true
  sensitive_data     = false
}

data "aws_caller_identity" "current" {}
