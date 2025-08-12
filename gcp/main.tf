# Random ID for unique resource naming
resource "random_id" "deployment_suffix" {
  byte_length = 4
  keepers = {
    project_id = local.project_id
    vpc_name   = var.vpc_name
  }
}

data "google_client_config" "current" {}

data "google_compute_zones" "available" {
  project = local.project_id
  region  = local.region
}

locals {
  unique_suffix = var.unique_suffix != "" ? var.unique_suffix : random_id.deployment_suffix.hex
  region        = data.google_client_config.current.region
  project_id    = data.google_client_config.current.project
  zones         = length(var.zones) > 0 ? var.zones : slice(data.google_compute_zones.available.names, 0, min(3, length(data.google_compute_zones.available.names)))
}

# VPC Module - Creates network infrastructure for scanner instances
module "vpc" {
  source = "./modules/vpc"

  name          = var.vpc_name
  subnet_cidr   = var.subnet_cidr
  unique_suffix = local.unique_suffix

  enable_ssh = var.enable_ssh
}

# Agentless Scanner Service Account Module - Service account for compute instances
module "agentless_scanner_service_account" {
  source = "./modules/agentless-scanner-service-account"

  unique_suffix = local.unique_suffix
}

# Agentless Impersonated Service Account Module - IAM resources for disk scanning
module "agentless_impersonated_service_account" {
  source = "./modules/agentless-impersonated-service-account"

  scanner_service_account_email = module.agentless_scanner_service_account.scanner_service_account_email
  unique_suffix                 = local.unique_suffix
}

# Instance Module - Managed Instance Group for Agentless Scanners
module "instance" {
  source = "./modules/instance"

  zones                 = local.zones
  network_name          = module.vpc.vpc_name
  subnetwork_name       = module.vpc.subnet_name
  service_account_email = module.agentless_scanner_service_account.scanner_service_account_email

  api_key            = var.api_key
  site               = var.site
  ssh_public_key     = var.ssh_public_key
  ssh_username       = var.ssh_username
  instance_count     = var.instance_count
  scanner_version    = var.scanner_version
  scanner_channel    = var.scanner_channel
  scanner_repository = var.scanner_repository
  unique_suffix      = local.unique_suffix

  depends_on = [module.vpc]
}
