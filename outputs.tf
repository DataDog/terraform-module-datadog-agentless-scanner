output "vpc" {
  description = "The VPC created for the Datadog agentless scanner"
  value       = module.vpc.vpc
}

output "api_key_secret_arn" {
  description = "The ARN of the secret containing the Datadog API key"
  value       = module.user_data.api_key_secret_arn
}
