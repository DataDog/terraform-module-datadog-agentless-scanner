output "service_account" {
  description = "The service account to be impersonated by Datadog Agentless Scanner for reading disk information"
  value       = google_service_account.target_service_account
}

output "service_account_email" {
  description = "Email of the target service account"
  value       = google_service_account.target_service_account.email
}

output "service_account_name" {
  description = "Name of the target service account"
  value       = google_service_account.target_service_account.name
}
