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

output "custom_role" {
  description = "The custom role for reading disk information"
  value       = google_project_iam_custom_role.target_role
}

output "custom_role_name" {
  description = "Name of the custom target role"
  value       = google_project_iam_custom_role.target_role.name
}
