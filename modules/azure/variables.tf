variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
  nullable    = false
}

variable "admin_ssh_key" {
  description = "SSH public key of the admin user"
  type        = string
}

variable "api_key_vault_id" {
  description = "The resource ID of the Key Vault holding the Datadog API key"
  type        = string
  sensitive   = true
}

variable "api_key_secret_name" {
  description = "The name of the secret in the Key Vault holding the Datadog API key"
  type        = string
  sensitive   = true
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = null
}

variable "location" {
  description = "The location where the Datadog Agentless Scanner resources will be created"
  type        = string
  nullable    = false
}

variable "scan_scopes" {
  description = "The set of scopes that the Agentless Scanner should be allowed to scan. Defaults to the scanner subscription."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "bastion" {
  description = "Create a bastion in the subnet"
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "A map of additional tags to add to the resources created"
  type        = map(string)
  default     = {}
}
