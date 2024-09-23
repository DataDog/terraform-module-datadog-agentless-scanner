
variable "tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "iam_delegate_role_name" {
  description = "Reference name to the Agentless delegate role"
  type        = string
  default     = "DatadogAgentlessScannerDelegateRole"
}

variable "iam_rds_assume_role_name" {
  description = "Reference name to the Agentless RDS assume role"
  type        = string
  default     = "DatadogAgentlessScannerRDSS3ExportRole"
}
