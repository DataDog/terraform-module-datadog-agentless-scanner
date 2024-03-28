output "vnet" {
  description = "The Azure Virtual Network created for the Datadog agentless scanner"
  value       = module.virtual_network.vnet
}

# TODO
#output "api_key_secret_arn" {
#  description = "The ARN of the secret containing the Datadog API key"
#  value       = module.user_data.api_key_secret_arn
#}
