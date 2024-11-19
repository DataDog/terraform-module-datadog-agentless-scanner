variable "api_key" {
  description = "Specifies the API key required by the Datadog Agent to submit vulnerabilities to Datadog"
  sensitive   = true
  type        = string
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"
  nullable    = false
}

variable "client_id" {
  description = "Client ID of the managed identity used by the Datadog Agentless Scanner"
  type        = string
  nullable    = false
}

variable "scanner_version" {
  description = "Specifies the version of the scanner to install"
  type        = string
  default     = "0.11"
}

variable "scanner_channel" {
  description = "Specifies the channel to use for installing the scanner"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta", "nightly"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable', 'beta' or 'nightly'"
  }
}

variable "scanner_repository" {
  description = "Repository URL to install the scanner from."
  type        = string
  default     = "https://apt.datadoghq.com/"
  validation {
    condition     = can(regex("^https://", var.scanner_repository))
    error_message = "The scanner repository must be a valid HTTPs URL"
  }
}

variable "scanner_configuration" {
  description = "Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner."
  type        = any
  default     = {}
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent."
  type        = any
  default     = {}
}
