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
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=7993939f19df2a39c981cbffbcd48a91c9fba214"

  site     = var.datadog_site
  api_key  = var.datadog_api_key
  vpc_name = "datadog-agentless-scanner"

  # The module automatically distributes instances across multiple zones in the configured region
  instance_count = 1
}

