variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  sensitive   = true
  type        = string
}

variable "site" {
  description = "The site of your Datadog account. Choose from: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  nullable    = false

  validation {
    condition = contains([
      "datadoghq.com",
      "us3.datadoghq.com",
      "us5.datadoghq.com",
      "datadoghq.eu",
      "ap1.datadoghq.com"
    ], var.site)
    error_message = "The site must be one of: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1)."
  }
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
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)."
  }
}

variable "scanner_channel" {
  description = "Specifies the channel to use for installing the scanner"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta", "nightly"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable', 'beta' or 'nightly'."
  }
}

variable "scanner_repository" {
  description = "Repository URL to install the scanner from."
  type        = string
  default     = "https://apt.datadoghq.com/"
  validation {
    condition     = can(regex("^https://", var.scanner_repository))
    error_message = "The scanner repository must be a valid HTTPs URL."
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
