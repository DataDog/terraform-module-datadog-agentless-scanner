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

# Create a single impersonated service account for the shared scanner service account
# This allows all scanner instances (across all regions) to scan resources in this project
module "agentless_impersonated_service_account" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-impersonated-service-account?ref=0.11.12"

  scanner_service_account_email = var.scanner_service_account_email
}
