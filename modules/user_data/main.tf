locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

data "aws_region" "current" {}

locals {
  agent_version      = "50.3"
  scanner_version    = "7.51.0~agentless~scanner~2024022201"
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
    api_key_secret_arn = local.api_key_secret_arn
    site               = var.site,
    agent_version      = local.agent_version,
    scanner_version    = local.scanner_version,
    region             = data.aws_region.current.name,
  })
}
