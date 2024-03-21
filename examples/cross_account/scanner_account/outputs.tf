output "scanner_role" {
  description = "The Datadog agentless scanner role created"
  value       = module.scanner_role.role.arn
}
