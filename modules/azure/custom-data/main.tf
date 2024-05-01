locals {
  agent_version   = "52.0"
  scanner_version = "0.11.0"
}

resource "terraform_data" "template" {
  input = templatefile("${path.module}/templates/install.sh.tftpl", {
    api_key         = var.api_key
    site            = var.site,
    agent_version   = local.agent_version,
    scanner_version = local.scanner_version,
    region          = var.location,
  })
}
