output "scanner_service_account_email" {
  description = "Email of the shared scanner service account that needs impersonation permissions in other projects"
  value       = module.scanner_service_account.scanner_service_account_email
}

output "vpc_network_name_us" {
  description = "The name of the VPC network created for the scanner in US"
  value       = module.datadog_agentless_scanner_us.vpc_network_name
}

output "vpc_network_name_eu" {
  description = "The name of the VPC network created for the scanner in EU"
  value       = module.datadog_agentless_scanner_eu.vpc_network_name
}
