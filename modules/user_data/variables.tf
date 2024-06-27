variable "api_key" {
  description = "Specifies the API key required by the Datadog Agent to submit vulnerabilities to Datadog"
  sensitive   = true
  type        = string
  default     = null
}

variable "scanner_version" {
  description = "Specifies the version of the scanner to install"
  type        = string
  default     = "0.11"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.scanner_version))
    error_message = "The scanner version must be in the format of X.Y"
  }
}

variable "scanner_channel" {
  description = "Specifies the channel to use for installing the scanner"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable' or 'beta'"
  }
}

variable "scanner_configuration" {
  description = "Specifies a custom configuration for the scanner. The specified object will be passed directly as a configuration input for the scanner."
  type        = any
  default     = {}
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the datadog-agent. The specified object will be passed directly as a configuration input for the datadog-agent."
  type        = any
  default     = {}
}

variable "api_key_secret_arn" {
  description = "ARN of the secret holding the Datadog API key. Takes precedence over api_key variable"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default     = {}
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"
  nullable    = false
}
