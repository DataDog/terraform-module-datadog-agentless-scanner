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
  project = var.scanned_project_id
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

# Enable agentless scanning for this project
resource "datadog_agentless_scanning_gcp_scan_options" "scanned_project" {
  gcp_project_id     = var.scanned_project_id
  vuln_host_os       = true
  vuln_containers_os = true
}

# Create an impersonated service account for the scanner service account
# This allows the scanner to scan resources in this project
module "agentless_impersonated_service_account" {
  source = "../../../modules/agentless-impersonated-service-account"

  scanner_service_account_email = var.scanner_service_account_email
}
