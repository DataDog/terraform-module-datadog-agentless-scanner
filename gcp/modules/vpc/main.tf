locals {
  vpc_name = "${var.name}-${var.unique_suffix}"
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
  description             = "VPC network for Datadog Agentless Scanner"
}

# Subnet for instances
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.vpc_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  description   = "Subnet for Datadog Agentless Scanner instances"

  # Enable private Google access for instances without external IPs
  private_ip_google_access = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  name    = "${local.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id

  description = "Cloud Router for NAT Gateway"
}

# NAT Gateway for outbound internet access from private instances
resource "google_compute_router_nat" "nat" {
  name                               = "${local.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule to allow health checks from Google Cloud
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.vpc_name}-allow-health-checks"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Google Cloud health check ranges
  target_tags   = ["datadog-agentless-scanner"]       # Same tag as instances
  description   = "Allow health checks from Google Cloud health check systems"
}

# Firewall rule to allow SSH access (if enabled)
resource "google_compute_firewall" "allow_ssh" {
  count   = var.enable_ssh ? 1 : 0
  name    = "${local.vpc_name}-allow-ssh-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # Google IAP source range
  target_tags   = ["datadog-agentless-scanner"]
  description   = "Allow SSH access via Identity-Aware Proxy to instances with datadog-agentless-scanner tag"
}
