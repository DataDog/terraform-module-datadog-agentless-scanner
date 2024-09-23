
variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "iam_delegate_role_arn" {
  description = "The ARN of the Agentless Scanner Delegate role"
  type        = string
}

variable "rds_service_role_arn" {
  description = "The ARN of the service role used by RDS to write the export to the S3 bucket"
  type        = string
}

variable "primary_kms_key_arn" {
  description = "Primary KMS key ARN to encrypt the exported data"
  type        = string
}

variable "primary_kms_key_region" {
  description = "The region of the primary KMS key"
  type        = string
}
