variable "datadog_api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  type        = string
}

variable "datadog_site" {
  description = "The site of your Datadog account. Choose from: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"

  validation {
    condition = contains([
      "datadoghq.com",
      "us3.datadoghq.com",
      "us5.datadoghq.com",
      "datadoghq.eu",
      "ap1.datadoghq.com"
    ], var.datadog_site)
    error_message = "The datadog_site must be one of: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1)."
  }
}

variable "datadog_integration_role" {
  description = "Role name of the Datadog integration that was used to integrate the AWS account to Datadog"
  type        = string
}
