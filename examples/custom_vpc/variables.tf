variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to launch in"
  type        = string
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}
