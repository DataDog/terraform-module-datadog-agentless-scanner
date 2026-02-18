# Outputs from Instance Module
output "instance_group_manager" {
  description = "The managed instance group manager"
  value       = module.instance.instance_group_manager
}

output "instance_template" {
  description = "The instance template used by the MIG"
  value       = module.instance.instance_template
}

output "health_check" {
  description = "The health check for auto-healing"
  value       = module.instance.health_check
}

output "mig_target_size" {
  description = "Target size of the managed instance group"
  value       = module.instance.mig_target_size
}

# Outputs from Agentless Impersonated Service Account Module
output "target_service_account_email" {
  description = "Email of the target service account"
  value       = module.agentless_impersonated_service_account.service_account_email
}

output "scanner_service_account_email" {
  description = "Email of the scanner service account"
  value       = local.effective_service_account_email
}

output "api_key_secret_id" {
  description = "The ID of the Secret Manager secret containing the Datadog API key"
  value       = module.instance.api_key_secret_id
}

# Outputs from VPC Module
output "vpc_network" {
  description = "The VPC network created for the scanner"
  value       = module.vpc.vpc
}

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "vpc_subnet" {
  description = "The subnet created for the scanner"
  value       = module.vpc.subnet
}

output "vpc_subnet_name" {
  description = "The name of the VPC subnet"
  value       = module.vpc.subnet_name
}

output "unique_suffix" {
  description = "Unique suffix used in resource names"
  value       = local.unique_suffix
}

output "zones" {
  description = "Zones where instances are deployed"
  value       = module.instance.zones
}
