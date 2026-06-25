variable "api_key" {
  description = "The Datadog API key to validate against the configured site. When empty, the check is skipped."
  sensitive   = true
  type        = string
  default     = null
}

variable "site" {
  description = "The Datadog site the API key is expected to belong to. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"
  nullable    = false
}
