variable "datadog_api_key" {
  description = "Datadog API key"
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

variable "datadog_integration_role" {
  description = "Role name of the Datadog integration that was used to integrate the AWS account to Datadog"
  type        = string
}
