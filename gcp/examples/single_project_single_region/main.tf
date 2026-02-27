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
  project = var.project_id
  region  = "us-central1"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

resource "datadog_agentless_scanning_gcp_scan_options" "scan_options" {
  gcp_project_id     = var.project_id
  vuln_host_os       = true
  vuln_containers_os = true
}

# ── Project-scoped resources (created once) ──

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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-scanner-service-account?ref=0.11.13"

  api_key_secret_id = google_secret_manager_secret.dd_api_key.id
}

module "impersonated_service_account" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-impersonated-service-account?ref=0.11.13"

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
}

# ── Scanner infrastructure ──

module "datadog_agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.13"

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
  api_key_secret_id             = google_secret_manager_secret.dd_api_key.id
  site                          = var.datadog_site
  vpc_name                      = "datadog-agentless-scanner"
}

# ── State migration ──
# These moved blocks migrate resources that were previously created inside
# the scanner module to their new top-level addresses. They allow Terraform
# to update the state in-place instead of destroying and recreating resources.
# You can safely remove these blocks after the first successful apply.

moved {
  from = module.datadog_agentless_scanner.module.agentless_scanner_service_account[0]
  to   = module.scanner_service_account
}

moved {
  from = module.datadog_agentless_scanner.module.agentless_impersonated_service_account[0]
  to   = module.impersonated_service_account
}

moved {
  from = module.datadog_agentless_scanner.module.instance.google_secret_manager_secret.api_key_secret[0]
  to   = google_secret_manager_secret.dd_api_key
}

moved {
  from = module.datadog_agentless_scanner.module.instance.google_secret_manager_secret_version.api_key_version[0]
  to   = google_secret_manager_secret_version.dd_api_key
}
