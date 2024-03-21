output "delegate_role" {
  description = "The Datadog agentless delegate role created"
  value       = module.delegate_role.role.arn
}
