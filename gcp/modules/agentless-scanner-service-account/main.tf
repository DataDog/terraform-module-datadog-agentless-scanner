data "google_client_config" "current" {}

# Random ID for unique resource naming when unique_suffix is empty
resource "random_id" "deployment_suffix" {
  byte_length = 4
}

locals {
  project_id = data.google_client_config.current.project
  # Use provided unique_suffix or generate random one
  effective_suffix = var.unique_suffix != "" ? var.unique_suffix : random_id.deployment_suffix.hex
  # Extract secret names from full paths (projects/PROJECT_ID/secrets/SECRET_NAME -> SECRET_NAME)
  secret_names = { for id in var.api_key_secret_ids : id => regex("^projects/[a-zA-Z0-9-]+/secrets/([a-zA-Z0-9-]+)$", id)[0] }
}

# Service account for the scanner
resource "google_service_account" "scanner_service_account" {
  account_id   = "dd-agentless-scanner-${local.effective_suffix}"
  display_name = "Scanner Service Account"
  description  = "Service account for the scanner"
}

# Custom role for attaching disks
resource "google_project_iam_custom_role" "attach_disk" {
  role_id     = "scannerAttachDisk${title(local.effective_suffix)}"
  title       = "Datadog Agentless Scanner"
  description = "Custom role for creating and attaching disks to instances"
  permissions = [
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.setLabels",
    "compute.disks.use",

    "compute.instances.attachDisk",
    "compute.instances.detachDisk",
  ]
}

# Binding the attach disk role to the scanner service account
resource "google_project_iam_member" "attach_disk_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.attach_disk.name
  member  = "serviceAccount:${google_service_account.scanner_service_account.email}"
  condition {
    title       = "Restrict to datadog-agentless disks"
    description = "Only allow operations on disks starting with datadog-agentless"
    expression  = <<-EOT
      resource.name.extract("disks/{name}").startsWith("datadog-agentless") ||
      resource.name.extract("instances/{name}").startsWith("datadog-agentless")
    EOT
  }
}

# Custom role for zone operations (cannot be restricted with conditions)
resource "google_project_iam_custom_role" "zone_operations" {
  role_id     = "scannerZoneOps${title(local.effective_suffix)}"
  title       = "Datadog Agentless Scanner - Zone Operations"
  description = "Custom role for checking zone operation status"
  permissions = [
    "compute.disks.list",
    "compute.zoneOperations.get",
  ]
}

# Binding for zone operations
resource "google_project_iam_member" "zone_operations_binding" {
  project = local.project_id
  role    = google_project_iam_custom_role.zone_operations.name
  member  = "serviceAccount:${google_service_account.scanner_service_account.email}"
}

# Binding the secretmanager secret accessor role to the scanner service account for each secret
resource "google_secret_manager_secret_iam_member" "scanner_secret_access" {
  for_each  = local.secret_names
  project   = local.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.scanner_service_account.email}"
}

# Allow the scanner service account to use itself
resource "google_service_account_iam_member" "self_impersonation_binding" {
  service_account_id = google_service_account.scanner_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.scanner_service_account.email}"
}
