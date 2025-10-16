data "google_client_config" "current" {}

# Random ID for unique resource naming when unique_suffix is empty
resource "random_id" "deployment_suffix" {
  byte_length = 4
  count       = var.unique_suffix == "" ? 1 : 0
}

locals {
  project_id = data.google_client_config.current.project
  # Use provided unique_suffix or generate random one
  effective_suffix = var.unique_suffix != "" ? var.unique_suffix : random_id.deployment_suffix[0].hex
}

# Custom role for creating snapshots
resource "google_project_iam_custom_role" "create_snapshot" {
  role_id = "datadogAgentlessTarget${title(local.effective_suffix)}"
  title   = "Datadog Agentless Target Role"

  description = "Custom role for Datadog Agentless scanner"
  permissions = [
    "compute.disks.createSnapshot",
    "compute.disks.get",

    "compute.images.get",

    "compute.snapshots.create",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.delete",
    "compute.snapshots.setLabels",

    "compute.globalOperations.get",
  ]
}

resource "google_service_account" "target_service_account" {
  account_id   = "dd-agentless-target-${local.effective_suffix}"
  display_name = "Datadog Agentless Target Service Account"
  description  = "Service account to be impersonated by Datadog Agentless Scanner for reading disk information"
}

# Binding the custom role to the service account
resource "google_project_iam_member" "agentless_role_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.create_snapshot.name
  member  = "serviceAccount:${google_service_account.target_service_account.email}"
}

# Binding the predefined role to the service account
resource "google_project_iam_member" "agentless_artifactregistry_role_binding" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
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
  role_id = "datadogAgentlessSnapshotReadonly${title(local.effective_suffix)}"
  title   = "Datadog Agentless Snapshot Readonly Role"

  description = "Custom role for Datadog Agentless scanner to read snapshots"
  permissions = [
    "compute.snapshots.useReadOnly",
    "compute.images.useReadOnly",
  ]
}

resource "google_project_iam_member" "agentless_use_snapshot_role_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.snapshot_readonly_role.name
  member  = "serviceAccount:${var.scanner_service_account_email}"
  condition {
    title       = "Limit to snapshots created by the scanner"
    description = "This condition ensures that the scanner can only access snapshots that it created."
    expression  = <<EOT
resource.name.extract("projects/${local.project_id}/global/snapshots/{name}").startsWith("datadog-agentless") ||
resource.name.startsWith("projects/${local.project_id}/global/images/")
EOT
  }
}
