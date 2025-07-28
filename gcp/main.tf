provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Module - Creates network infrastructure for scanner instances
module "vpc" {
  source = "./modules/vpc"

  name        = var.vpc_name
  region      = var.region
  subnet_cidr = var.subnet_cidr

  enable_nat = var.enable_nat
  enable_ssh = var.enable_ssh

  tags = var.tags
}

# Agentless Impersonated Service Account Module - IAM resources for disk scanning
module "agentless_impersonated_service_account" {
  source = "./modules/agentless-impersonated-service-account"

  project_id = var.project_id
}

# Agentless Scanner Service Account Module - Service account for compute instances
module "agentless_scanner_service_account" {
  source = "./modules/agentless-scanner-service-account"

  project_id                        = var.project_id
  impersonated_service_account_name = module.agentless_impersonated_service_account.disk_reader_service_account_name
}

# Instance Module - Managed Instance Group for Agentless Scanners
module "instance" {
  source = "./modules/instance"

  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
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

  depends_on = [module.vpc]
}
