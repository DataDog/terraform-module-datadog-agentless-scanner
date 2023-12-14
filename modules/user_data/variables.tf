variable "hostname" {
  description = "Specifies the hostname the agentless-scanning agent will report as"
  type        = string
}

variable "api_key" {
  description = "Specifies the API keys required by the Datadog Agent to submit vulnerabilities to Datadog"
  type        = string
  sensitive   = true
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
  default     = "50.0~rc.7~agentless~scanner~2023121302"
  nullable    = false
}

variable "agent_repo_url" {
  description = "Specifies the agent distribution channel"
  type        = string
  default     = "datad0g.com"
  nullable    = false
}
