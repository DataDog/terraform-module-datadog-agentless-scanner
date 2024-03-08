data "aws_region" "current" {}

locals {
  agent_version   = "50.3"
  scanner_version = "7.51.0~agentless~scanner~2024022201"
}

resource "terraform_data" "template" {
  lifecycle {
    precondition {
      condition     = var.api_key != null || var.api_key_secret_arn != null
      error_message = "Please provide either api_key or api_key_secret_arn"
    }
  }
  input = templatefile("${path.module}/templates/install.sh.tftpl", {
    api_key            = var.api_key,
    api_key_secret_arn = var.api_key_secret_arn
    site               = var.site,
    agent_version      = local.agent_version,
    scanner_version    = local.scanner_version,
    region             = data.aws_region.current.name,
  })
}
