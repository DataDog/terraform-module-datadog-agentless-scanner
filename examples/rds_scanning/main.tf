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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.10"

  account_roles = [module.delegate_role.role.arn]
  api_key_secret_arns = [
    module.agentless_scanner_us.api_key_secret_arn,
    module.agentless_scanner_eu.api_key_secret_arn,
  ]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.10"

  scanner_roles                       = [module.agentless_scanner_role.role.arn]
  sensitive_data_scanning_rds_enabled = true
}

module "agentless_scanner_us" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.10"

  providers = {
    aws = aws.us
  }

  api_key               = var.api_key
  instance_profile_name = module.agentless_scanner_role.instance_profile.name
}

module "agentless_scanner_eu" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.10"

  providers = {
    aws = aws.eu
  }

  api_key               = var.api_key
  instance_profile_name = module.agentless_scanner_role.instance_profile.name
}


module "agentless_s3_bucket_us" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-s3-bucket?ref=0.11.10"

  iam_delegate_role_name  = module.delegate_role.role.name
  iam_rds_assume_role_arn = module.agentless_scanner_us.role.arn

  providers = {
    aws = aws.us
  }
}

module "agentless_s3_bucket_eu" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-s3-bucket?ref=0.11.10"

  iam_delegate_role_name  = module.delegate_role.role.name
  iam_rds_assume_role_arn = module.agentless_scanner_eu.role.arn

  providers = {
    aws = aws.eu
  }
}

module "autoscaling_scanners" {
  source                   = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanners-autoscaling?ref=0.11.10"
  datadog_integration_role = var.datadog_integration_role
}
