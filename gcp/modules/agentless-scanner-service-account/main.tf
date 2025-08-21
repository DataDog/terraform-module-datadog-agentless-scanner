data "google_client_config" "current" {}

locals {
  project_id = data.google_client_config.current.project
}

# Service account for the scanner
resource "google_service_account" "scanner_service_account" {
  account_id   = "dd-agentless-scanner-${var.unique_suffix}"
  display_name = "Scanner Service Account"
  description  = "Service account for the scanner"
}

# Custom role for attaching disks
resource "google_project_iam_custom_role" "attach_disk" {
  role_id     = "scannerAttachDisk${title(var.unique_suffix)}"
  title       = "Datadog Agentless Scanner"
  description = "Custom role for creating and attaching disks to instances"
  permissions = [
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.disks.use",
    "compute.instances.attachDisk",

    "compute.zoneOperations.get",
  ]
}

# Binding the attach disk role to the scanner service account
resource "google_project_iam_member" "attach_disk_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.attach_disk.name
  member  = "serviceAccount:${google_service_account.scanner_service_account.email}"
}

# Binding the secretmanager secret accessor role to the scanner service account
resource "google_secret_manager_secret_iam_member" "scanner_secret_access" {
  project   = local.project_id
  secret_id = var.api_key_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.scanner_service_account.email}"
}

# Allow the scanner service account to use itself
resource "google_service_account_iam_member" "self_impersonation_binding" {
  service_account_id = google_service_account.scanner_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.scanner_service_account.email}"
}
