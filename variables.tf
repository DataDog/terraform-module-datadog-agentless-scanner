variable "api_key" {
  description = "Specifies the API keys required by the Datadog Agent to submit vulnerabilities to Datadog"
  type        = string
  sensitive   = true
  default     = null
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
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.scanner_version))
    error_message = "The scanner version must be in the format of X.Y"
  }
}

variable "scanner_channel" {
  description = "Channel of the scanner to install from (stable or beta)"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable' or 'beta'"
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
  description = "Specifies a custom configuration for the scanner. The specified object will be passed directly as a configuration input for the scanner."
  type        = any
  default     = {}
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the datadog-agent. The specified object will be passed directly as a configuration input for the datadog-agent."
  type        = any
  default     = {}
}
