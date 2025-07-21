output "instance_group_manager" {
  description = "The managed instance group manager"
  value       = google_compute_instance_group_manager.agentless_scanner_mig.id
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
  value       = google_compute_instance_group_manager.agentless_scanner_mig.target_size
}

output "ssh_command" {
  description = "SSH command to connect to instances in the group"
  value       = "gcloud compute ssh --zone=${var.zone} agentless-scanner-* --tunnel-through-iap"
}

output "mig_management_commands" {
  description = "Useful commands for managing the MIG"
  value = {
    list_instances     = "gcloud compute instance-groups managed list-instances agentless-scanner-mig --zone=${var.zone}"
    describe_mig       = "gcloud compute instance-groups managed describe agentless-scanner-mig --zone=${var.zone}"
    recreate_instances = "gcloud compute instance-groups managed recreate-instances agentless-scanner-mig --zone=${var.zone} --instances=INSTANCE_NAME"
    manual_refresh     = "gcloud compute instance-groups managed recreate-instances agentless-scanner-mig --zone=${var.zone}"
  }
} 
