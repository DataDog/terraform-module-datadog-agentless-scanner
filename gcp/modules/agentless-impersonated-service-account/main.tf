data "google_client_config" "current" {}

locals {
  project_id = data.google_client_config.current.project
}

# Custom role for reading disk information
resource "google_project_iam_custom_role" "target_role" {
  role_id = "datadogAgentlessTarget${title(var.unique_suffix)}"
  title   = "Datadog Agentless Target Role"

  description = "Custom role for Datadog Agentless scanner"
  permissions = [
    "compute.disks.createSnapshot",
    "compute.disks.get",

    "compute.snapshots.create",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.delete",
    "compute.snapshots.setLabels",

    "compute.globalOperations.get",
  ]
}

resource "google_service_account" "target_service_account" {
  account_id   = "dd-agentless-target-${var.unique_suffix}"
  display_name = "Datadog Agentless Target Service Account"
  description  = "Service account to be impersonated by Datadog Agentless Scanner for reading disk information"
}

# Binding the custom role to the service account
resource "google_project_iam_member" "agentless_role_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.target_role.name
  member  = "serviceAccount:${google_service_account.target_service_account.email}"
}

# Binding the scanner service account to the impersonated service account
resource "google_service_account_iam_member" "impersonation_binding" {
  service_account_id = google_service_account.target_service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.scanner_service_account_email}"
}

# Custom role for reading snapshots
resource "google_project_iam_custom_role" "snapshot_readonly_role" {
  role_id = "datadogAgentlessSnapshotReadonly${title(var.unique_suffix)}"
  title   = "Datadog Agentless Snapshot Readonly Role"

  description = "Custom role for Datadog Agentless scanner to read snapshots"
  permissions = [
    "compute.snapshots.useReadOnly",
  ]
}

resource "google_project_iam_member" "agentless_use_snapshot_role_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.snapshot_readonly_role.name
  member  = "serviceAccount:${var.scanner_service_account_email}"
  condition {
    title       = "Limit to snapshots created by the scanner"
    description = "This condition ensures that the scanner can only access snapshots that it created."
    expression  = "resource.name.extract(\"projects/${local.project_id}/global/snapshots/{name}\").startsWith(\"datadog-agentless\")"
  }
}
