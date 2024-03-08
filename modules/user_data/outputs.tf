output "install_sh" {
  description = "The installation script for the Datadog agentless scanner"
  value       = terraform_data.template.output
}

output "agent_version" {
  description = "The version of the Datadog Agent installed"
  value       = local.agent_version
}

output "scanner_version" {
  description = "The version of the Datadog Agentless Scanner installed"
  value       = local.scanner_version
}
