output "service_account" {
  description = "The service account to be impersonated by Datadog Agentless Scanner for reading disk information"
  value       = google_service_account.delegate_service_account
}

output "service_account_email" {
  description = "Email of the delegate service account"
  value       = google_service_account.delegate_service_account.email
}

output "service_account_name" {
  description = "Name of the delegate service account"
  value       = google_service_account.delegate_service_account.name
}

output "custom_role" {
  description = "The custom role for reading disk information"
  value       = google_project_iam_custom_role.delegate_role
}

output "custom_role_name" {
  description = "Name of the custom delegate role"
  value       = google_project_iam_custom_role.delegate_role.name
}
