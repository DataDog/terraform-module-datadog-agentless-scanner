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
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

resource "datadog_agentless_scanning_aws_scan_options" "scan_options" {
  aws_account_id     = data.aws_caller_identity.current.account_id
  vuln_host_os       = true
  vuln_containers_os = true
  lambda             = true
  sensitive_data     = false
}

module "scanner_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.12"

  api_key_secret_arns = [module.agentless_scanner.api_key_secret_arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.12"

  scanner_roles = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.12"

  api_key               = var.datadog_api_key
  site                  = var.datadog_site
  instance_profile_name = module.scanner_role.instance_profile.name
}

module "autoscaling_scanners" {
  source                   = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanners-autoscaling?ref=0.11.12"
  datadog_integration_role = var.datadog_integration_role
}
