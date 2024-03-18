output "vpc" {
  description = "The VPC created for the Datadog agentless scanner"
  value       = aws_vpc.vpc
}

output "public_subnets" {
  description = "The public subnets of the created VPC"
  value       = aws_subnet.public
}

output "private_subnets" {
  description = "The private subnets of the created VPC"
  value       = aws_subnet.private
}

output "nap_public_id" {
  description = "The public IP associated with the VPC's NAT"
  value       = aws_eip.nat.public_ip
}

output "routing_ready" {
  description = "Indicates whether routing resources have been successfully provisioned"
  value       = true

  depends_on = [
    aws_route.private,
    aws_route.public
  ]
}
