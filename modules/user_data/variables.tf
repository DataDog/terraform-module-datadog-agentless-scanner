variable "hostname" {
  description = "Specifies the hostname the agentless-scanning agent will report as"
  type        = string
}

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

variable "scanner_version" {
  description = "Specifies the agentless scanner version installed"
  type        = string
  default     = "50.0~agentless~scanner~2024011701"
  nullable    = false
}

variable "agent_repo_url" {
  description = "Specifies the agent distribution channel"
  type        = string
  default     = "datad0g.com"
  nullable    = false
}
