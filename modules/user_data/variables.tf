variable "api_key" {
  description = "Specifies the API key required by the Datadog Agent to submit vulnerabilities to Datadog"
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
  default     = "datadoghq.com"
  nullable    = false
}

variable "agent_version" {
  description = "Specifies the agent version installed"
  type        = string
  default     = "50.3"
  nullable    = false
}

variable "scanner_version" {
  description = "Specifies the agentless scanner version installed"
  type        = string
  default     = "7.50.0~agentless~scanner~2024020101"
  nullable    = false
}
