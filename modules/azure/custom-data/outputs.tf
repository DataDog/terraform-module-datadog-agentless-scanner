output "install_sh" {
  description = "The installation script for the Datadog agentless scanner"
  value       = terraform_data.template.output
}

output "scanner_version" {
  description = "The version of the Datadog Agentless Scanner installed"
  value       = local.scanner_version
}
