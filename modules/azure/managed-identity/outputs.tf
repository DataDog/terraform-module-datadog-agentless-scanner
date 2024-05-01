output "identity" {
  description = "The managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances"
  value       = azurerm_user_assigned_identity.managed_identity
}
