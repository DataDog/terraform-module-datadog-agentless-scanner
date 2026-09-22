variable "datadog_api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  type        = string
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
}

variable "datadog_site" {
  description = "The site of your Datadog account, e.g. datadoghq.com (US1), datadoghq.eu (EU), ap1.datadoghq.com (AP1). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
}

variable "aws_account_ids" {
  description = "List of AWS account IDs to activate the Agentless Scanning for. Note that an Agentless Scanning delegate role must be created in each of these accounts."
  type        = set(string)
}
