variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = "DatadogAgentlessScannerAgentRole"
}

variable "allowed_organizational_unit_ids" {
  description = "List of AWS Organizations organizational units (OUs) that are allowed to assume the Datadog agentless scanner role"
  type        = list(string)
  default     = ["*"]
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
  description = "List of cross accounts roles ARN that the Datadog agentless scanner can assume - make sure to respect the same naming convention as the agentless scanner role."
  type        = list(string)
  default     = ["arn:*:iam::*:role/DatadogAgentlessScannerDelegateRole"]
}

variable "api_key_secret_arns" {
  description = "List of ARNs of the secrets holding the Datadog API keys"
  type        = list(string)
  validation {
    condition     = length(var.api_key_secret_arns) > 0
    error_message = "api_key_secret_arns must not be empty"
  }
}

variable "api_key_secret_kms_key_arns" {
  description = "List of ARNs of the KMS keys encrypting the secrets"
  type        = list(string)
  default     = []
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
