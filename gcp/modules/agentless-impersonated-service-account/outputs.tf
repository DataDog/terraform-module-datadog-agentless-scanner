output "disk_reader_service_account" {
  description = "The service account for reading disk information"
  value       = google_service_account.disk_reader_sa
}

output "disk_reader_service_account_email" {
  description = "Email of the disk reader service account"
  value       = google_service_account.disk_reader_sa.email
}

output "disk_reader_service_account_name" {
  description = "Name of the disk reader service account"
  value       = google_service_account.disk_reader_sa.name
}

output "disk_reader_custom_role" {
  description = "The custom role for reading disk information"
  value       = google_project_iam_custom_role.disk_reader
}

output "disk_reader_custom_role_name" {
  description = "Name of the custom disk reader role"
  value       = google_project_iam_custom_role.disk_reader.name
} 
