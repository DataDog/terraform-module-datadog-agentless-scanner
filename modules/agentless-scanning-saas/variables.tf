variable "datadog_integration_role" {
  description = "Role name of the Datadog integration used to integrate the AWS account to Datadog. Datadog assumes this role to perform the scans."
  type        = string
}

variable "sensitive_data_scanning_enabled" {
  description = "Installs specific permissions to enable scanning of S3 buckets"
  type        = bool
  default     = true
}

variable "iam_policy_path" {
  description = "IAM policy path"
  type        = string
  default     = "/"
}
