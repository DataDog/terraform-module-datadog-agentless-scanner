output "impersonated_service_account_email_us" {
  description = "Email of the impersonated service account created in this project for US scanner"
  value       = module.agentless_impersonated_service_account_us.service_account_email
}

output "impersonated_service_account_email_eu" {
  description = "Email of the impersonated service account created in this project for EU scanner"
  value       = module.agentless_impersonated_service_account_eu.service_account_email
}
