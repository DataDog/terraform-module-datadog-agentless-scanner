variable "datadog_api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  type        = string
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
}

variable "datadog_site" {
  description = "The site of your Datadog account. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"
}

variable "datadog_integration_role" {
  description = "Role name of the Datadog integration that was used to integrate the AWS account to Datadog"
  type        = string
}
