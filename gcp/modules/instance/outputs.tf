output "instance_group_manager" {
  description = "The managed instance group manager"
  value       = google_compute_region_instance_group_manager.agentless_scanner_mig.id
}

output "instance_template" {
  description = "The instance template used by the MIG"
  value       = google_compute_instance_template.agentless_scanner_template.id
}

output "health_check" {
  description = "The health check for auto-healing"
  value       = google_compute_health_check.agentless_scanner_health.id
}

output "mig_target_size" {
  description = "Target size of the managed instance group"
  value       = google_compute_region_instance_group_manager.agentless_scanner_mig.target_size
}

output "zones" {
  description = "Zones where instances are distributed"
  value       = var.zones
}
