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

output "ssh_command" {
  description = "SSH command to connect to instances in the group"
  value       = module.instance.ssh_command
}

output "mig_management_commands" {
  description = "Useful commands for managing the MIG"
  value       = module.instance.mig_management_commands
}

# Outputs from Agentless Impersonated Service Account Module
output "disk_reader_service_account_email" {
  description = "Email of the disk reader service account"
  value       = module.agentless_impersonated_service_account.disk_reader_service_account_email
}

output "disk_reader_custom_role_name" {
  description = "Name of the custom disk reader role"
  value       = module.agentless_impersonated_service_account.disk_reader_custom_role_name
}

output "scanner_service_account_email" {
  description = "Email of the scanner service account"
  value       = module.agentless_scanner_service_account.scanner_service_account_email
}
