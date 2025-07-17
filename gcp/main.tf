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

# Compute instance
resource "google_compute_instance" "default" {
  name         = "instance-moez-2"
  machine_type = "e2-small"
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
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

  # Configure SSH access and startup script via metadata
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
}

# Output the external IP for SSH access
output "instance_external_ip" {
  description = "External IP address of the instance"
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh ${var.ssh_username}@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}

output "instance_name" {
  description = "Name of the instance"
  value       = google_compute_instance.default.name
}

output "instance_zone" {
  description = "Zone of the instance"
  value       = google_compute_instance.default.zone
}

output "instance_tags" {
  description = "Tags applied to the instance"
  value       = google_compute_instance.default.tags
}

output "firewall_rule_name" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.name
}
