variable "role_name" {
  description = "Name of the IAM role to attach the scanning policy to"
  type        = string
}

variable "policy_name_prefix" {
  description = "Name prefix of the IAM policy created"
  type        = string
  default     = "DatadogAgentlessScanningPolicy"
}

variable "policy_path" {
  description = "IAM policy path"
  type        = string
  default     = "/"
}

variable "sensitive_data_scanning_enabled" {
  description = "Installs specific permissions to enable scanning of S3 buckets"
  type        = bool
  default     = true
}
