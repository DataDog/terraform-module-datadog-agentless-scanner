variable "name" {
  description = "The name of the user-assigned managed identity to be used by the Datadog Agentless Scanner virtual machine instances."
  type        = string
  nullable    = false
  default     = "DatatogAgentlessScannerIdentity"
}

variable "location" {
  description = "The Azure region where the managed identity should exist."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "The name of the resource group within which the managed identity should exist."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "A map of additional tags to add to the managed identity."
  type        = map(string)
  nullable    = false
  default     = {}
}
