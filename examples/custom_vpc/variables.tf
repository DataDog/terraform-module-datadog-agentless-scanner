variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to launch in"
  type        = string
}

variable "subnet_ids" {
  description = "The VPC Subnet IDs to launch in"
  type        = list(string)
}

variable "datadog_site" {
  description = "The site of your Datadog account, e.g. datadoghq.com (US1), datadoghq.eu (EU), ap1.datadoghq.com (AP1). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
}

variable "datadog_integration_role" {
  description = "Role name of the Datadog integration that was used to integrate the AWS account to Datadog"
  type        = string
}
