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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role?ref=0.11.10"

  api_key_secret_arns = [module.agentless_scanner.api_key_secret_arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role?ref=0.11.10"

  scanner_roles = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner?ref=0.11.10"

  api_key               = var.api_key
  instance_profile_name = module.scanner_role.instance_profile.name

  # It is possible to provide any agent configuration from this parameter.
  # The given HCL structure is encoded in YAML and used as configuration for the Datadog Agent.
  # They should respect the configuration schema of the Agent that is described here: https://github.com/DataDog/datadog-agent/blob/main/pkg/config/config_template.yaml
  agent_configuration = {
    # Providing specific tags for the scanner instance
    tags = [
      "env:staging",
      "foo:bar",
    ],

    # Providing additional_endpoints for dual shipping of metrics
    # https://docs.datadoghq.com/agent/configuration/dual-shipping/
    additional_endpoints = {
      "https://app.datadoghq.com" = [
        "ENC[arn:aws:secretsmanager:us-east-1:734986933288:secret:scanner/api_key_ddstaging]"
      ]
    }

    # Providing additional_endpoints for dual shipping of logs
    # https://docs.datadoghq.com/agent/configuration/dual-shipping/
    logs_config = {
      additional_endpoints = [
        {
          api_key = "ENC[arn:aws:secretsmanager:us-east-1:734986933288:secret:scanner/api_key_ddstaging]"
          host    = "ddstaging-http-intake.logs.datadoghq.com."
        }
      ]
    }
  }

  scanner_configuration = {
    # Providing dual shipping of SBOMs
    sbom_additional_endpoints = [
      {
        api_key = "ENC[arn:aws:secretsmanager:us-east-1:xxxx:secret:xxxx]"
        Host    = "sbom-intake.datadoghq.com"
      }
    ]
  }
}
