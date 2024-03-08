variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = "DatadogAgentlessScannerAgentRole"
}

variable "iam_policy_name" {
  description = "Name to use on IAM policy created"
  type        = string
  default     = "DatadogAgentlessScannerAgentPolicy"
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = "/"
}

variable "iam_policy_path" {
  description = "IAM policy path"
  type        = string
  default     = null
}

variable "account_roles" {
  description = "List of cross accounts roles ARN that the Datadog agentless scanner can assume"
  type        = list(string)
  default     = []
}

variable "api_key_secret_arn" {
  description = "ARN of the secret holding the Datadog API key"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "ARN of the KMS key encrypting the secret"
  type        = string
  default     = null
}

variable "enable_ssm" {
  description = "Whether to enable AWS SSM to facilitate executing troubleshooting commands on the instance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}
