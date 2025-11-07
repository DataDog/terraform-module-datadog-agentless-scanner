terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.scanned_project_id
}

# Create impersonated service accounts for each scanner service account (US and EU)
# This allows both the US and EU scanners to scan resources in this project

module "agentless_impersonated_service_account_us" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-impersonated-service-account?ref=7993939f19df2a39c981cbffbcd48a91c9fba214"

  scanner_service_account_email = var.scanner_service_account_email_us
  unique_suffix                 = "${var.unique_suffix}us"
}

module "agentless_impersonated_service_account_eu" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-impersonated-service-account?ref=7993939f19df2a39c981cbffbcd48a91c9fba214"

  scanner_service_account_email = var.scanner_service_account_email_eu
  unique_suffix                 = "${var.unique_suffix}eu"
}
