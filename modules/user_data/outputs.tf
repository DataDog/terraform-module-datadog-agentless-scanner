output "install_sh" {
  description = "The installation script for the Datadog agentless scanner"
  value       = terraform_data.template.output
}

output "api_key_secret_arn" {
  description = "The ARN of the API key secret"
  value       = local.api_key_secret_arn
}

output "agent_version" {
  description = "The version of the Datadog Agent installed"
  value       = local.agent_version
}

output "scanner_version" {
  description = "The version of the Datadog Agentless Scanner installed"
  value       = var.scanner_version
}
