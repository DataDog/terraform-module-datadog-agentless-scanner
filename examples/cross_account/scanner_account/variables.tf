variable "api_key" {
  description = "Specifies the API keys required by the Datadog Agent to submit vulnerabilities to Datadog"
  type        = string
}

variable "cross_account_delegate_arn" {
  description = "Specifies the ARN of the delegate role created for cross account scanning"
  type        = string
}
