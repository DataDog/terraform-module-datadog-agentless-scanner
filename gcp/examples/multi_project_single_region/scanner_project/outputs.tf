output "scanner_service_account_email" {
  description = "Email of the scanner service account that needs impersonation permissions in other projects"
  value       = module.scanner_service_account.scanner_service_account_email
}

output "vpc_network_name" {
  description = "The name of the VPC network created for the scanner"
  value       = module.datadog_agentless_scanner.vpc_network_name
}
