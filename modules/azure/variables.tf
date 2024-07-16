variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
  nullable    = false
}

variable "admin_ssh_key" {
  description = "SSH public key of the admin user"
  type        = string
}

variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog"
  type        = string
  sensitive   = true
  default     = null
}

variable "api_key_secret_id" {
  description = "The versionless resource ID of the Azure Key Vault secret holding the Datadog API key. Ignored if api_key is specified."
  type        = string
  default     = null
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
  description = "The set of scopes that the Agentless Scanner should be allowed to scan. Defaults to the scanner subscription. Ignored when scanner_identity is set."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "scanner_identity" {
  description = "A user assigned identity to assign to the Agentless Scanner VMs. It is recommended to leave this unset, in which case a new identity will be created with the required role assignments."
  type = object({
    client_id = string
    id        = string
  })
  default = null
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
