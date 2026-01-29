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

module "user_data" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/user_data?ref=0.11.12"

  api_key = var.api_key
}

module "agentless_scanner_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.12"

  api_key_secret_arns = [module.user_data.api_key_secret_arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.12"

  scanner_roles = [module.agentless_scanner_role.role.arn]
}

module "instance" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/instance?ref=0.11.12"

  user_data            = module.user_data.install_sh
  iam_instance_profile = module.agentless_scanner_role.instance_profile.name
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
}

module "autoscaling_scanners" {
  source                   = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanners-autoscaling?ref=0.11.12"
  datadog_integration_role = var.datadog_integration_role
}
