# Service account for the scanner
resource "google_service_account" "scanner_service_account" {
  account_id   = "scanner-service-account"
  display_name = "Scanner Service Account"
  description  = "Service account for the scanner"
}

# Binding the service account to the custom role for impersonation
resource "google_service_account_iam_member" "impersonation_binding" {
  service_account_id = var.impersonated_service_account_name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.scanner_service_account.email}"
}
