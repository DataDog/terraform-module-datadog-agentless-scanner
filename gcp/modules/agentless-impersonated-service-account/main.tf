# Custom role for reading disk information

resource "google_project_iam_custom_role" "target_role" {
  role_id = "datadogAgentlessDelegate${title(var.unique_suffix)}"
  title   = "Datadog Agentless Delegate Role"

  description = "Custom role for Datadog Agentless scanner"
  permissions = [
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.create",
    "compute.disks.use",
    "compute.disks.createSnapshot",

    "compute.snapshots.create",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.setLabels",
    "compute.snapshots.useReadOnly",

    "compute.diskTypes.get",
    "compute.diskTypes.list",

    "compute.instances.list", # offline mode

    "compute.globalOperations.get",
    "compute.zoneOperations.get",
  ]
}

resource "google_service_account" "target_service_account" {
  account_id   = "dd-agentless-target-${var.unique_suffix}"
  display_name = "Datadog Agentless Target Service Account"
  description  = "Service account to be impersonated by Datadog Agentless Scanner for reading disk information"
}

# Binding the custom role to the service account
resource "google_project_iam_member" "agentless_role_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.target_role.name
  member  = "serviceAccount:${google_service_account.target_service_account.email}"
}

# Binding the scanner service account to the impersonated service account
resource "google_service_account_iam_member" "impersonation_binding" {
  service_account_id = google_service_account.target_service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.scanner_service_account_email}"
}
