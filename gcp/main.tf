provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Firewall rule to allow SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-terraform"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Custom role for reading disk information
resource "google_project_iam_custom_role" "disk_reader" {
  role_id     = "diskReader"
  title       = "Disk Reader"
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
# Service account for reading disk information
resource "google_service_account" "disk_reader_sa" {
  account_id   = "disk-reader-sa"
  display_name = "Disk Reader Service Account"
  description  = "Service account for reading disk information"
}

# Binding the custom role to the service account
resource "google_project_iam_member" "disk_reader_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.disk_reader.name
  member  = "serviceAccount:${google_service_account.disk_reader_sa.email}"
}

# Service account for the compute instance
resource "google_service_account" "compute_instance_sa" {
  account_id   = "compute-instance-sa"
  display_name = "Compute Instance Service Account"
  description  = "Service account for the compute instance"
}

# Binding the service account to the custom role
resource "google_service_account_iam_member" "impersonation_binding" {
  service_account_id = google_service_account.disk_reader_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.compute_instance_sa.email}"
}

# Instance Template for Managed Instance Group
resource "google_compute_instance_template" "agentless_scanner_template" {
  name_prefix  = "agentless-scanner-template-"
  description  = "Template for Datadog Agentless Scanner instances"
  machine_type = "e2-small"

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    auto_delete  = true
    boot         = true
    disk_size_gb = 30
    disk_type    = "pd-standard"
  }

  network_interface {
    network    = "projects/${var.project_id}/global/networks/${var.network_name}"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork_name}"
    access_config {} # This gives the VM an external IP
  }

  service_account {
    email  = google_service_account.compute_instance_sa.email
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

  tags = ["http-server", "ssh-enabled"]

  lifecycle {
    create_before_destroy = true
  }
}

# Health Check for Auto-healing
resource "google_compute_health_check" "agentless_scanner_health" {
  name                = "agentless-scanner-health-check"
  description         = "Health check for Datadog Agentless Scanner"
  check_interval_sec  = 60
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = 22 # SSH port as basic connectivity check
  }

  log_config {
    enable = true
  }
}

# Managed Instance Group (Autoscaling Group) - Zonal
resource "google_compute_instance_group_manager" "agentless_scanner_mig" {
  name = "agentless-scanner-mig"
  zone = var.zone

  base_instance_name = "agentless-scanner"
  target_size        = var.instance_count # Configurable size - will auto-replace if instance fails

  version {
    instance_template = google_compute_instance_template.agentless_scanner_template.id
  }

  # Auto-healing configuration
  auto_healing_policies {
    health_check      = google_compute_health_check.agentless_scanner_health.id
    initial_delay_sec = 300 # Wait 5 minutes before starting health checks
  }

  # Update policy for rolling updates (simpler for zonal MIG)
  update_policy {
    type           = "PROACTIVE"
    minimal_action = "REPLACE"

    max_surge_fixed       = 0 # Must be 0 when using RECREATE method
    max_unavailable_fixed = 1 # Allow 1 instance to be unavailable during recreate
    replacement_method    = "RECREATE"
  }

  named_port {
    name = "ssh"
    port = 22
  }
}

# Outputs for Managed Instance Group
output "instance_group_manager" {
  description = "The managed instance group manager"
  value       = google_compute_instance_group_manager.agentless_scanner_mig.id
}

output "instance_template" {
  description = "The instance template used by the MIG"
  value       = google_compute_instance_template.agentless_scanner_template.id
}

output "health_check" {
  description = "The health check for auto-healing"
  value       = google_compute_health_check.agentless_scanner_health.id
}

output "mig_target_size" {
  description = "Target size of the managed instance group"
  value       = google_compute_instance_group_manager.agentless_scanner_mig.target_size
}

output "ssh_command" {
  description = "SSH command to connect to instances in the group"
  value       = "gcloud compute ssh --zone=${var.zone} agentless-scanner-* --tunnel-through-iap"
}

output "firewall_rule_name" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.name
}

output "mig_management_commands" {
  description = "Useful commands for managing the MIG"
  value = {
    list_instances     = "gcloud compute instance-groups managed list-instances agentless-scanner-mig --zone=${var.zone}"
    describe_mig       = "gcloud compute instance-groups managed describe agentless-scanner-mig --zone=${var.zone}"
    recreate_instances = "gcloud compute instance-groups managed recreate-instances agentless-scanner-mig --zone=${var.zone} --instances=INSTANCE_NAME"
  }
}
