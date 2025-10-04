output "vpc" {
  description = "The VPC network created for the Datadog agentless scanner"
  value       = google_compute_network.vpc
}

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet" {
  description = "The subnet created for the Datadog agentless scanner"
  value       = google_compute_subnetwork.subnet
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "network_name" {
  description = "The name of the VPC network (for backward compatibility)"
  value       = google_compute_network.vpc.name
}

