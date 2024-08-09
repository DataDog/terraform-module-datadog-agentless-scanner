resource "terraform_data" "template" {
  input = templatefile("${path.module}/templates/install.sh.tftpl", {
    api_key               = var.api_key
    site                  = var.site,
    azure_client_id       = var.client_id,
    scanner_version       = var.scanner_version,
    scanner_channel       = var.scanner_channel,
    scanner_configuration = var.scanner_configuration,
    agent_configuration   = var.agent_configuration,
  })
}
