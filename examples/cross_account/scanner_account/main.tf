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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.4"

  ## By default the scanner can assume any role with the default naming
  ## convention from any account.
  #
  # account_roles = ["arn:*:iam::*:role/DatadogAgentlessScannerDelegateRole"]

  ## Is is also possible explicitly lists the roles the scanner can assume if
  ## you changed the name of the delegate role:
  #
  # account_roles = ["arn:*:iam::111111111111:role/MyDatadogAgentlessScannerDelegateRole"]

  ## The account_org_paths variable can restrict the scanner to only be
  ## allowed to assume roles from specific AWS Organizations organizational
  ## unit (OU) paths.
  ## reference: https://aws.amazon.com/blogs/security/how-to-control-access-to-aws-resources-based-on-aws-account-ou-or-organization/
  #
  # account_org_paths = [
  #  "o-acorg/r-acroot/ou-acroot-mediaou/",
  #  "o-acorg/r-acroot/ou-acroot-sportsou/*",
  # ]

  api_key_secret_arns = [module.agentless_scanner.api_key_secret_arn]
}

module "self_delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.4"

  scanner_roles = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.4"

  api_key               = var.api_key
  instance_profile_name = module.scanner_role.instance_profile.name
}
