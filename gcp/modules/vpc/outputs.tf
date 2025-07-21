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

output "subnetwork_name" {
  description = "The name of the subnet (for backward compatibility)"
  value       = google_compute_subnetwork.subnet.name
}

output "router" {
  description = "The Cloud Router (if NAT is enabled)"
  value       = var.enable_nat ? google_compute_router.router[0] : null
}

output "nat_gateway" {
  description = "The NAT Gateway (if enabled)"
  value       = var.enable_nat ? google_compute_router_nat.nat[0] : null
}

output "private_service_connect_address" {
  description = "The Private Service Connect address (if enabled)"
  value       = var.enable_private_service_connect ? google_compute_global_address.private_service_connect[0].address : null
} 
