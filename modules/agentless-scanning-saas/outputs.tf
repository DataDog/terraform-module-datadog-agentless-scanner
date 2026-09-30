output "scanning_policy" {
  description = "The customer managed policy attached to the Datadog integration role"
  value       = module.scanning_policy.policy
}
