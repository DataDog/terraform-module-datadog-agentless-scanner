# Note: SSH firewall rule is now managed by the VPC module

# Instance Template for Managed Instance Group
resource "google_compute_instance_template" "agentless_scanner_template" {
  name_prefix  = "agentless-scanner-template-${var.unique_suffix}-"
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
    network    = "projects/${var.project_id}/global/networks/${var.network_name}"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork_name}"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.ssh_username}:${var.ssh_public_key}" : null
    enable-oslogin = "FALSE"
    startup-script = templatefile("${path.module}/startup-script.sh.tftpl", {
      api_key            = var.api_key
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
  name                = "agentless-scanner-health-check-${var.unique_suffix}"
  description         = "Health check for Datadog Agentless Scanner"
  check_interval_sec  = 60
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = 8080 # Health check port for application health check
  }

  log_config {
    enable = true
  }
}

# Managed Instance Group (Autoscaling Group) - Regional
resource "google_compute_region_instance_group_manager" "agentless_scanner_mig" {
  name   = "agentless-scanner-mig-${var.unique_suffix}"
  region = var.region

  base_instance_name = "agentless-scanner-${var.unique_suffix}"
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
