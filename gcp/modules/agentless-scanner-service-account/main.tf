# Service account for the scanner
resource "google_service_account" "scanner_service_account" {
  account_id   = "dd-agentless-scanner-${var.unique_suffix}"
  display_name = "Scanner Service Account"
  description  = "Service account for the scanner"
}

# Custom role for attaching disks
resource "google_project_iam_custom_role" "attach_disk" {
  role_id     = "scannerAttachDisk${title(var.unique_suffix)}"
  title       = "Scanner Attach Disk"
  description = "Custom role for attaching disks to instances"
  permissions = [
    "compute.instances.attachDisk",
    "compute.disks.use",
  ]
}

# Binding the attach disk role to the scanner service account
resource "google_project_iam_member" "attach_disk_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.attach_disk.name
  member  = "serviceAccount:${google_service_account.scanner_service_account.email}"
}

# Allow the scanner service account to use itself
resource "google_service_account_iam_member" "self_impersonation_binding" {
  service_account_id = google_service_account.scanner_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.scanner_service_account.email}"
}
