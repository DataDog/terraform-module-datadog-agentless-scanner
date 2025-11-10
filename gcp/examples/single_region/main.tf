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
  project = var.project_id
  region  = "us-central1"
}

module "datadog_agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.11.12"

  site     = var.datadog_site
  api_key  = var.datadog_api_key
  vpc_name = "datadog-agentless-scanner"
}
