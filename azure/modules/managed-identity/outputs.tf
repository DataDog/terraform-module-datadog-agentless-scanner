output "identity" {
  description = "The user-assigned managed identity to be used by the Datadog Agentless Scanner virtual machine instances."
  value       = azurerm_user_assigned_identity.identity
}
