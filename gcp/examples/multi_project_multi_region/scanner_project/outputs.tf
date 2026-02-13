output "scanner_service_account_email_us" {
  description = "Email of the scanner service account in US region that needs impersonation permissions in other projects"
  value       = module.datadog_agentless_scanner_us.scanner_service_account_email
}

output "scanner_service_account_email_eu" {
  description = "Email of the scanner service account in EU region that needs impersonation permissions in other projects"
  value       = module.datadog_agentless_scanner_eu.scanner_service_account_email
}

output "vpc_network_name_us" {
  description = "The name of the VPC network created for the scanner in US"
  value       = module.datadog_agentless_scanner_us.vpc_network_name
}

output "vpc_network_name_eu" {
  description = "The name of the VPC network created for the scanner in EU"
  value       = module.datadog_agentless_scanner_eu.vpc_network_name
}
