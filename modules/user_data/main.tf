data "aws_region" "current" {}

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
    agent_version      = var.agent_version,
    scanner_version    = var.scanner_version,
    region             = data.aws_region.current.name,
  })
}
