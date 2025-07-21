output "scanner_service_account" {
  description = "The scanner service account"
  value       = google_service_account.scanner_service_account
}

output "scanner_service_account_email" {
  description = "Email of the scanner service account"
  value       = google_service_account.scanner_service_account.email
}

output "scanner_service_account_name" {
  description = "Name of the scanner service account"
  value       = google_service_account.scanner_service_account.name
}
