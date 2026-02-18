terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.81.0"
    }
  }
}

# Default provider for project-scoped resources (service accounts, secrets)
provider "google" {
  project = var.scanner_project_id
}

provider "google" {
  project = var.scanner_project_id
  region  = "us-central1"
  alias   = "us"
}

provider "google" {
  project = var.scanner_project_id
  region  = "europe-west1"
  alias   = "eu"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

# Enable agentless scanning for the scanner project
resource "datadog_agentless_scanning_gcp_scan_options" "scanner_project" {
  gcp_project_id     = var.scanner_project_id
  vuln_host_os       = true
  vuln_containers_os = true
}

# ── Project-scoped resources (created once, shared across regions) ──

resource "google_secret_manager_secret" "dd_api_key" {
  secret_id = "datadog-agentless-scanner-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "dd_api_key" {
  secret      = google_secret_manager_secret.dd_api_key.id
  secret_data = var.datadog_api_key
}

module "scanner_service_account" {
  source = "../../../modules/agentless-scanner-service-account"

  api_key_secret_id = google_secret_manager_secret.dd_api_key.id
}

module "impersonated_service_account" {
  source = "../../../modules/agentless-impersonated-service-account"

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
}

# ── Regional infrastructure (per region, symmetric) ──

# Deploy the scanner infrastructure in US region
module "datadog_agentless_scanner_us" {
  source = "../../../"

  providers = {
    google = google.us
  }

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
  api_key_secret_id             = google_secret_manager_secret.dd_api_key.id
  site                          = var.datadog_site
  vpc_name                      = "datadog-agentless-scanner-us"
}

# Deploy the scanner infrastructure in EU region
module "datadog_agentless_scanner_eu" {
  source = "../../../"

  providers = {
    google = google.eu
  }

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
  api_key_secret_id             = google_secret_manager_secret.dd_api_key.id
  site                          = var.datadog_site
  vpc_name                      = "datadog-agentless-scanner-eu"
}
