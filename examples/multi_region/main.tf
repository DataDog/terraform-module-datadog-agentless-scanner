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
  alias  = "us"
}

provider "aws" {
  region = "eu-central-1"
  alias  = "eu"
}

module "agentless_scanner_role" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.6.0"

  account_roles = [module.delegate_role.role.arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.6.0"

  scanner_roles = [module.agentless_scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner?ref=0.6.0"
  providers = {
    aws = aws.us
  }

  api_key               = var.api_key
  instance_profile_name = module.agentless_scanner_role.instance_profile.name
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner?ref=0.6.0"
  providers = {
    aws = aws.eu
  }

  api_key               = var.api_key
  instance_profile_name = module.agentless_scanner_role.instance_profile.name
}
