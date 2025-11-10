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
  project = var.scanner_project_id
  region  = "us-central1"
  alias   = "us"
}

provider "google" {
  project = var.scanner_project_id
  region  = "europe-west1"
  alias   = "eu"
}

# Deploy the scanner infrastructure in US region
module "datadog_agentless_scanner_us" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.12"

  providers = {
    google = google.us
  }

  site     = var.datadog_site
  api_key  = var.datadog_api_key
  vpc_name = "datadog-agentless-scanner-us"
}

# Deploy the scanner infrastructure in EU region
module "datadog_agentless_scanner_eu" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.12"

  providers = {
    google = google.eu
  }

  site     = var.datadog_site
  api_key  = var.datadog_api_key
  vpc_name = "datadog-agentless-scanner-eu"
}
