variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  sensitive   = true
  type        = string
  default     = null
}

variable "scanner_version" {
  description = "Specifies the version of the scanner to install"
  type        = string
  default     = "0.11"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)"
  }
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
  description = "Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner. Warning: this is an advanced feature and can break the scanner if not used correctly."
  type        = any
  default     = {}
  validation {
    condition     = can(yamlencode(var.scanner_configuration))
    error_message = "The scanner_configuration variable cannot be properly encoded to YAML"
  }
  validation {
    condition     = !contains(keys(var.scanner_configuration), "api_key") && !contains(keys(var.scanner_configuration), "hostname") && !contains(keys(var.scanner_configuration), "site")
    error_message = "The scanner_configuration cannot override the 'api_key', 'hostname', or 'site' fields."
  }
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent. For more details: https://docs.datadoghq.com/agent/configuration/agent-configuration-files/. Warning: this is an advanced feature and can break the Datadog Agent if not used correctly."
  type        = any
  default     = {}
  validation {
    condition     = can(yamlencode(var.agent_configuration))
    error_message = "The agent_configuration variable cannot be properly encoded to YAML"
  }
  validation {
    condition     = !contains(keys(var.agent_configuration), "api_key") && !contains(keys(var.agent_configuration), "hostname") && !contains(keys(var.agent_configuration), "site") && !contains(keys(var.agent_configuration), "logs_enabled") && !contains(keys(var.agent_configuration), "ec2_prefer_imdsv2")
    error_message = "The agent_configuration cannot override the 'api_key', 'hostname', or 'site' fields."
  }
}

variable "api_key_secret_arn" {
  description = "ARN of the secret holding the Datadog API key. Takes precedence over api_key variable - Make sure the API key is Remote Configuration enabled."
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
