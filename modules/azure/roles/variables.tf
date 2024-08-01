variable "resource_group_id" {
  description = "The ID of the resource group where the Datadog Agentless Scanner exists."
  type        = string
  nullable    = false
}

variable "principal_id" {
  description = "The object (principal) ID of the user-assigned identity used by the Datadog Agentless Scanner."
  type        = string
  nullable    = false
}

variable "api_key_secret_id" {
  description = "The resource ID of the Key Vault secret holding the Datadog API key."
  type        = string
  nullable    = true
  default     = null
}

variable "scan_scopes" {
  description = "The set of scopes that the Datadog Agentless Scanner is allowed to scan."
  type        = list(string)
  nullable    = false
  validation {
    condition = alltrue([
      for s in var.scan_scopes : can(regex("^(?i:/subscriptions/([a-f0-9-]{36}))/?$", s))
    ])
    error_message = "All scan scopes must be subscriptions."
  }
}
