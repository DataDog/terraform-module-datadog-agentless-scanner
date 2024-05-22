variable "name" {
  description = "Name of the managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances"
  type        = string
  default     = "DatatogAgentlessScanner"
}

variable "location" {
  description = "The location where the Datadog Agentless Scanner resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the managed identity will be created"
  type        = string
}

variable "resource_group_id" {
  description = "The ID of the resource group to which the role assignment will be scoped"
  type        = string
}

variable "api_key_secret_id" {
  description = "The resource ID of the Key Vault secret holding the Datadog API key"
  type        = string
  nullable    = true
  default     = null
}

variable "scan_scopes" {
  description = "The set of scopes that the Agentless Scanner should be allowed to scan"
  type        = list(string)
  nullable    = false
}

variable "tags" {
  description = "A map of additional tags to add to the managed identity"
  type        = map(string)
  default     = {}
}
