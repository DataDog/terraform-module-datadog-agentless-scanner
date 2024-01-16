variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = "DatadogAgentlessScannerDelegateRole"
}

variable "iam_policy_name" {
  description = "Name to use on IAM policy created"
  type        = string
  default     = "DatadogAgentlessScannerDelegateRolePolicy"
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_policy_path" {
  description = "IAM policy path"
  type        = string
  default     = null
}

variable "scanner_roles" {
  description = "List of roles ARN allowed to assume this role"
  type        = list(string)
}

variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}
