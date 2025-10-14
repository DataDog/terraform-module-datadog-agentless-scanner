# Note: SSH firewall rule is now managed by the VPC module

data "google_client_config" "current" {}

# Random ID for unique resource naming when unique_suffix is empty
resource "random_id" "deployment_suffix" {
  byte_length = 4
  count       = var.unique_suffix == "" ? 1 : 0
}

locals {
  project_id        = data.google_client_config.current.project
  region            = data.google_client_config.current.region
  api_key_secret_id = var.api_key_secret_id != null ? var.api_key_secret_id : google_secret_manager_secret.api_key_secret[0].id
  # Use provided unique_suffix or generate random one
  effective_suffix = var.unique_suffix != "" ? var.unique_suffix : random_id.deployment_suffix[0].hex
  # Validation for api_key XOR api_key_secret_id
  api_key_validation = (var.api_key != null && var.api_key_secret_id == null) || (var.api_key == null && var.api_key_secret_id != null)
  # Validation to ensure both SSH variables are provided or neither
  ssh_validation = (var.ssh_public_key != null && var.ssh_username != null) || (var.ssh_public_key == null && var.ssh_username == null)
}

# Instance Template for Managed Instance Group
resource "google_compute_instance_template" "agentless_scanner_template" {
  name_prefix  = "datadog-agentless-scanner-template-${local.effective_suffix}-"
  description  = "Template for Datadog Agentless Scanner instances"
  machine_type = "n4-standard-2"

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-minimal-2404-lts-amd64"
    auto_delete  = true
    boot         = true
    disk_size_gb = 30
    disk_type    = "hyperdisk-balanced"
  }

  network_interface {
    network    = "projects/${local.project_id}/global/networks/${var.network_name}"
    subnetwork = "projects/${local.project_id}/regions/${local.region}/subnetworks/${var.subnetwork_name}"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.ssh_username}:${var.ssh_public_key}" : null
    enable-oslogin = "FALSE"
    startup-script = templatefile("${path.module}/startup-script.sh.tftpl", {
      api_key_secret_id  = local.api_key_secret_id
      site               = var.site
      scanner_version    = var.scanner_version
      scanner_repository = var.scanner_repository
      scanner_channel    = var.scanner_channel
    })
  }

  tags = ["datadog-agentless-scanner"]

  labels = {
    datadog                 = "true"
    datadogagentlessscanner = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Health Check for Auto-healing
resource "google_compute_health_check" "agentless_scanner_health" {
  name                = "datadog-agentless-scanner-health-check-${local.effective_suffix}"
  description         = "Health check for Datadog Agentless Scanner"
  check_interval_sec  = 60
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = 6253 # Health check port exposed by datadog-agentless-scanner
  }

  log_config {
    enable = true
  }
}

# Managed Instance Group (Autoscaling Group) - Regional
resource "google_compute_region_instance_group_manager" "agentless_scanner_mig" {
  name   = "datadog-agentless-scanner-mig-${local.effective_suffix}"
  region = local.region

  base_instance_name = "datadog-agentless-scanner-${local.effective_suffix}"
  target_size        = var.instance_count # Configurable size - will auto-replace if instance fails

  # Distribution policy to spread instances across specified zones
  distribution_policy_zones = var.zones

  version {
    instance_template = google_compute_instance_template.agentless_scanner_template.id
  }

  # Auto-healing configuration
  auto_healing_policies {
    health_check      = google_compute_health_check.agentless_scanner_health.id
    initial_delay_sec = 300 # Wait 5 minutes before starting health checks
  }

  # Update policy for rolling updates (enhanced for regional MIG)
  update_policy {
    type           = "PROACTIVE"
    minimal_action = "REPLACE"

    max_surge_fixed       = length(var.zones) # Allow one instance per zone during surge
    max_unavailable_fixed = 0                 # Must be 0 or >= number of zones for regional MIG
    replacement_method    = "SUBSTITUTE"      # Use SUBSTITUTE for better availability during updates
  }
}

resource "google_secret_manager_secret" "api_key_secret" {
  count     = var.api_key_secret_id != null ? 0 : 1
  secret_id = "datadog-agentless-scanner-api-key-${local.effective_suffix}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_key_version" {
  count       = var.api_key_secret_id != null ? 0 : 1
  secret      = google_secret_manager_secret.api_key_secret[0].id
  secret_data = var.api_key
}

# Validation to ensure exactly one of api_key or api_key_secret_id is provided
# NOTE: Using count-based validation instead of preconditions because preconditions were
# introduced in Terraform 1.2, which is too recent for our requirements.
# See: https://github.com/hashicorp/terraform/blob/v1.2/CHANGELOG.md
resource "null_resource" "api_key_validation" {
  count = local.api_key_validation ? 0 : 1

  triggers = {
    error = "Exactly one of 'api_key' or 'api_key_secret_id' must be provided, but not both."
  }
}

resource "null_resource" "ssh_validation" {
  count = local.ssh_validation ? 0 : 1

  triggers = {
    error = "Both 'ssh_public_key' and 'ssh_username' must be provided together, or neither should be provided."
  }
}
