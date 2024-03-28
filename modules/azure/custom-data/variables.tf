variable "location" {
  description = "The location of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
}

variable "api_key" {
  description = "Specifies the API key required by the Datadog Agent to submit vulnerabilities to Datadog"
  sensitive   = true
  type        = string
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
