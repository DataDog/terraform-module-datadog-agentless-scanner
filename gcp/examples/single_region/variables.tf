variable "project_id" {
  description = "The GCP project ID where the scanner will be deployed"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key with Remote Configuration enabled"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog APP key needed to enable the product"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "The Datadog site of your organization where scanner data will be sent (for example, datadoghq.com, datadoghq.eu, us3.datadoghq.com, us5.datadoghq.com, ap1.datadoghq.com, ddog-gov.com). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
}

