# Custom role for reading disk information
resource "google_project_iam_custom_role" "disk_reader" {
  role_id     = "datadogAgentlessDiskReader"
  title       = "Datadog Agentless Disk Reader"
  description = "Custom role for reading disk information"
  permissions = [
    "compute.disks.get",
    "compute.disks.list",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.diskTypes.get",
    "compute.diskTypes.list"
  ]
}

resource "google_service_account" "disk_reader_sa" {
  account_id   = "dd-agentless-disk-reader-sa"
  display_name = "Datadog Agentless Disk Reader Service Account"
  description  = "Service account to be impersonated by Datadog Agentless Scanner for reading disk information"
}

# Binding the custom role to the service account
resource "google_project_iam_member" "disk_reader_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.disk_reader.name
  member  = "serviceAccount:${google_service_account.disk_reader_sa.email}"
}
