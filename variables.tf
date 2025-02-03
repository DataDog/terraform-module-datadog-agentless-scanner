variable "api_key" {
  description = "Specifies the API keys required by the Datadog Agent to submit vulnerabilities to Datadog"
  type        = string
  sensitive   = true
  default     = null
  validation {
    condition     = can(var.api_key == null ? {} : regex("^[0-9a-f]{32}$", var.api_key))
    error_message = "api_key must be a Datadog API key (32 hexadecimal characters)"
  }
}

variable "api_key_secret_arn" {
  description = "ARN of the secret holding the Datadog API key. Takes precedence over api_key variable"
  type        = string
  default     = null
}

variable "scanner_version" {
  description = "Version of the scanner to install"
  type        = string
  default     = "0.11"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)"
  }
}

variable "scanner_channel" {
  description = "Channel of the scanner to install from (stable or beta)."
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

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Name of the instance profile to attach to the instance"
  type        = string
}

variable "enable_ssm" {
  description = "Whether to enable AWS SSM to facilitate executing troubleshooting commands on the instance"
  type        = bool
  default     = false
}

variable "enable_ssm_vpc_endpoint" {
  description = "Whether to enable AWS SSM VPC endpoint (only applicable if enable_ssm is true)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "scanner_configuration" {
  description = "Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner. Warning: this is an advanced feature and can break the scanner if not used correctly."
  type        = any
  default     = {}
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent. For more details: https://docs.datadoghq.com/agent/configuration/agent-configuration-files/. Warning: this is an advanced feature and can break the Datadog Agent if not used correctly."
  type        = any
  default     = {}
}

variable "instance_type" {
  description = "The type of instance running the scanner"
  type        = string
  default     = "t4g.large"
}

variable "instance_count" {
  description = "Size of the autoscaling group the instance is in (i.e. number of instances with scanners to run)"
  type        = number
  default     = 1
}
