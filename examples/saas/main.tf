terraform {
  required_version = ">= 1.0"

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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanning-policy?ref=0.13.0"
}

resource "aws_iam_policy" "agentless_scanning" {
  name_prefix = "DatadogAgentlessScanningPolicy"
  policy      = module.agentless_scanning_policy.json
}

resource "aws_iam_role_policy_attachment" "agentless_scanning" {
  role       = var.datadog_integration_role
  policy_arn = aws_iam_policy.agentless_scanning.arn
}

resource "datadog_agentless_scanning_aws_scan_options" "scan_options" {
  aws_account_id     = data.aws_caller_identity.current.account_id
  vuln_host_os       = true
  vuln_containers_os = true
  lambda             = true
  sensitive_data     = true
  compliance_host    = true

  depends_on = [aws_iam_role_policy_attachment.agentless_scanning]
}
