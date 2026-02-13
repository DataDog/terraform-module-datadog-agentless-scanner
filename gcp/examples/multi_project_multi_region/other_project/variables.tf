variable "scanned_project_id" {
  description = "The GCP project ID that will be scanned by the Agentless scanner"
  type        = string
}

variable "scanner_service_account_email_us" {
  description = "Email of the US scanner service account from the scanner project (output from scanner_project deployment)"
  type        = string
}

variable "scanner_service_account_email_eu" {
  description = "Email of the EU scanner service account from the scanner project (output from scanner_project deployment)"
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
  description = "The Datadog site of your organization where scanner data will be sent (for example, datadoghq.com, datadoghq.eu, us3.datadoghq.com, us5.datadoghq.com, ap1.datadoghq.com, ap2.datadoghq.com, ddog-gov.com). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
}
