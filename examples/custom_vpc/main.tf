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

module "agentless_scanner_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.6"
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.6"

  scanner_roles = [module.agentless_scanner_role.role.arn]
}

module "user_data" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/user_data?ref=0.11.6"

  hostname = "agentless-scanning-us-east-1"
  api_key  = var.api_key
}

module "instance" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/instance?ref=0.11.6"

  user_data            = module.user_data.install_sh
  iam_instance_profile = module.agentless_scanner_role.profile.name
  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
}
