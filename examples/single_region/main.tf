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
  region = "us-east-1"
}

module "scanner_role" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.7.0"

  account_roles = [module.delegate_role.role.arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.7.0"

  scanner_role = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner?ref=0.7.0"

  api_key               = var.api_key
  instance_profile_name = module.scanner_role.instance_profile.name
}
