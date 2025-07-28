# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.name
  auto_create_subnetworks = false
  description             = "VPC network for Datadog Agentless Scanner"
}

# Subnet for instances
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-subnet"
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  description   = "Subnet for Datadog Agentless Scanner instances"

  # Enable private Google access for instances without external IPs
  private_ip_google_access = true
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.vpc.id

  description = "Cloud Router for NAT Gateway"
}

# NAT Gateway for outbound internet access from private instances
resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  name                               = "${var.name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rule to allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
  description   = "Allow internal communication within VPC"
}

# Firewall rule to allow SSH access via IAP (if enabled)
resource "google_compute_firewall" "allow_ssh" {
  count   = var.enable_ssh ? 1 : 0
  name    = "${var.name}-allow-ssh-iap"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # Google IAP source range
  target_tags   = ["ssh-enabled"]
  description   = "Allow SSH access via Identity-Aware Proxy to instances with ssh-enabled tag"
}

# Firewall rule to allow HTTP/HTTPS access (if enabled)
resource "google_compute_firewall" "allow_http" {
  count   = var.enable_http ? 1 : 0
  name    = "${var.name}-allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
  description   = "Allow HTTP/HTTPS access to instances with http-server/https-server tags"
}

# Private Service Connect endpoint for Google APIs (optional)
resource "google_compute_global_address" "private_service_connect" {
  count        = var.enable_private_service_connect ? 1 : 0
  name         = "${var.name}-psc-address"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = google_compute_network.vpc.id
  address_type = "INTERNAL"
  description  = "Private Service Connect address for Google APIs"
}

resource "google_compute_global_forwarding_rule" "private_service_connect" {
  count                 = var.enable_private_service_connect ? 1 : 0
  name                  = "${var.name}-psc-endpoint"
  target                = "all-apis"
  network               = google_compute_network.vpc.id
  ip_address            = google_compute_global_address.private_service_connect[0].id
  load_balancing_scheme = ""
  description           = "Private Service Connect endpoint for Google APIs"
}
