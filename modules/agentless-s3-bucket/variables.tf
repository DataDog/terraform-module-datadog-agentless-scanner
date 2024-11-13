
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
