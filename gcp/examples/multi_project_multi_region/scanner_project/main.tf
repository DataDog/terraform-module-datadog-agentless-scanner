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

# Create a single shared service account for all scanner deployments
module "scanner_service_account" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-scanner-service-account?ref=0.11.12"

  api_key_secret_ids = [
    module.datadog_agentless_scanner_us.api_key_secret_id,
    module.datadog_agentless_scanner_eu.api_key_secret_id,
  ]
}

# Deploy the scanner infrastructure in US region
module "datadog_agentless_scanner_us" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.12"

  providers = {
    google = google.us
  }

  site                  = var.datadog_site
  api_key               = var.datadog_api_key
  vpc_name              = "datadog-agentless-scanner-us"
  service_account_email = module.scanner_service_account.scanner_service_account_email
}

# Deploy the scanner infrastructure in EU region
module "datadog_agentless_scanner_eu" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.12"

  providers = {
    google = google.eu
  }

  site                  = var.datadog_site
  api_key               = var.datadog_api_key
  vpc_name              = "datadog-agentless-scanner-eu"
  service_account_email = module.scanner_service_account.scanner_service_account_email
}
