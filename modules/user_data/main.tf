locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
  dd_tags_list = [for k, v in local.dd_tags : "${k}:${v}"]
}

data "aws_region" "current" {}

locals {
  api_key_secret_arn = var.api_key_secret_arn != null ? var.api_key_secret_arn : aws_secretsmanager_secret.api_key[0].arn
  # Add custom tags to the agent configuration.
  custom_agent_configuration = merge(
    var.agent_configuration,
    {
      tags = concat(
        lookup(var.agent_configuration, "tags", []), # Safely get existing tags or default to an empty list
        local.dd_tags_list
      )
    }
  )
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
  input = templatefile("${path.module}/templates/install.sh.tftpl", {
    api_key_secret_arn    = local.api_key_secret_arn
    site                  = var.site,
    scanner_version       = var.scanner_version,
    scanner_channel       = var.scanner_channel,
    scanner_repository    = var.scanner_repository,
    scanner_configuration = var.scanner_configuration,
    agent_configuration   = local.custom_agent_configuration,
    region                = data.aws_region.current.name,
  })
}
