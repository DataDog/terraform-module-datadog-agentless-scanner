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

variable "datadog_integration_role" {
  description = "Role name of the Datadog integration that was used to integrate the AWS account to Datadog"
  type        = string
}
