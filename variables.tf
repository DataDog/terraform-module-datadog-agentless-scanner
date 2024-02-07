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

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = null
}

variable "agent_version" {
  description = "Specifies the agent version installed"
  type        = string
  default     = null
}

variable "scanner_version" {
  description = "Specifies the agentless scanner version installed"
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
