locals {
  install_sh = templatefile("${path.module}/templates/install.sh.tftpl", {
    hostname        = var.hostname,
    api_key         = var.api_key,
    secret_arn      = var.secret_arn
    site            = var.site,
    scanner_version = var.scanner_version,
    agent_repo_url  = var.agent_repo_url,
  })
}
