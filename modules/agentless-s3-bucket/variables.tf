
variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "iam_delegate_role_arn" {
  description = "Reference ARN to the Agentless delegate role"
  type        = string
}

variable "iam_rds_assume_role_arn" {
  description = "Reference ARN to the Agentless RDS assume role"
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