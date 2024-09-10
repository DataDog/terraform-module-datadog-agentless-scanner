locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_region" "current" {}

locals {
  api_key_secret_arn = var.api_key_secret_arn != null ? var.api_key_secret_arn : aws_secretsmanager_secret.api_key[0].arn
}

resource "aws_secretsmanager_secret" "api_key" {
  count       = var.api_key_secret_arn != null ? 0 : 1
  name_prefix = "datadog-agentless-scanner-api-key"
  tags        = merge(var.tags, local.dd_tags)
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  count         = var.api_key_secret_arn != null ? 0 : 1
  secret_id     = aws_secretsmanager_secret.api_key[0].id
  secret_string = var.api_key
}

resource "terraform_data" "template" {
  lifecycle {
    precondition {
      condition     = (var.api_key != null && var.api_key_secret_arn == null) || (var.api_key == null && var.api_key_secret_arn != null)
      error_message = "Please provide either api_key or api_key_secret_arn"
    }
  }

  input = templatefile("${path.module}/templates/install.sh.tftpl", {
    api_key_secret_arn           = local.api_key_secret_arn
    site                         = var.site,
    scanner_version              = var.scanner_version,
    scanner_channel              = var.scanner_channel,
    scanner_configuration        = var.scanner_configuration,
    agent_configuration          = var.agent_configuration,
    security_agent_configuration = var.security_agent_configuration,
    system_probe_configuration   = var.system_probe_configuration
    region                       = data.aws_region.current.name,
  })
}
