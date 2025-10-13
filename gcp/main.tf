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
  # Validation to ensure exactly one of api_key or api_key_secret_id is provided
  api_key_validation = (var.api_key != null && var.api_key_secret_id == null) || (var.api_key == null && var.api_key_secret_id != null)
  # Validation to ensure both SSH variables are provided or neither
  ssh_validation = (var.ssh_public_key != null && var.ssh_username != null) || (var.ssh_public_key == null && var.ssh_username == null)
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
  api_key_secret_id  = var.api_key_secret_id
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

# NOTE: Using count-based validation instead of preconditions because preconditions were
# introduced in Terraform 1.2, which is too recent for our requirements.
# See: https://github.com/hashicorp/terraform/blob/v1.2/CHANGELOG.md
resource "null_resource" "api_key_validation" {
  count = local.api_key_validation ? 0 : 1

  triggers = {
    error = "Exactly one of 'api_key' or 'api_key_secret_id' must be provided, but not both."
  }
}

resource "null_resource" "ssh_validation" {
  count = local.ssh_validation ? 0 : 1

  triggers = {
    error = "Both 'ssh_public_key' and 'ssh_username' must be provided together, or neither should be provided."
  }
}
