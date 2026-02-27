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

# Instance Module - Managed Instance Group for Agentless Scanners
module "instance" {
  source = "./modules/instance"

  zones                 = local.zones
  network_name          = module.vpc.vpc_name
  subnetwork_name       = module.vpc.subnet_name
  service_account_email = var.scanner_service_account_email

  api_key_secret_id     = var.api_key_secret_id
  site                  = var.site
  ssh_public_key        = var.ssh_public_key
  ssh_username          = var.ssh_username
  instance_count        = var.instance_count
  scanner_version       = var.scanner_version
  scanner_channel       = var.scanner_channel
  scanner_repository    = var.scanner_repository
  scanner_configuration = var.scanner_configuration
  agent_configuration   = var.agent_configuration
  unique_suffix         = local.unique_suffix

  depends_on = [module.vpc]
}

# NOTE: Using count-based validation instead of preconditions because preconditions were
# introduced in Terraform 1.2, which is too recent for our requirements.
# See: https://github.com/hashicorp/terraform/blob/v1.2/CHANGELOG.md
resource "null_resource" "ssh_validation" {
  count = local.ssh_validation ? 0 : 1

  triggers = {
    error = "Both 'ssh_public_key' and 'ssh_username' must be provided together, or neither should be provided."
  }
}
