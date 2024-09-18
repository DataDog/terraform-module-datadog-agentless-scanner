output "vnet" {
  description = "The Azure Virtual Network created for the Datadog agentless scanner."
  value       = module.virtual_network.vnet
}
