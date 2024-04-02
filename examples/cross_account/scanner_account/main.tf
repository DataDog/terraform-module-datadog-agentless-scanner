terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "scanner_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/aws/agentless-scanner-role?ref=0.11.0"

  # compact remove empty value for cross_account_delegate_arn during the first run
  account_roles = compact([
    module.self_delegate_role.role.arn,
    var.cross_account_delegate_arn
  ])
  api_key_secret_arns = [module.agentless_scanner.api_key_secret_arn]
}

module "self_delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/aws/scanning-delegate-role?ref=0.11.0"

  scanner_roles = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.0"

  use_aws               = true
  api_key               = var.api_key
  instance_profile_name = module.scanner_role.instance_profile.name
}
