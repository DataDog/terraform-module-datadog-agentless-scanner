output "impersonated_service_account_email" {
  description = "Email of the impersonated service account created in this project for the scanner"
  value       = module.agentless_impersonated_service_account.service_account_email
}
