variable "sensitive_data_scanning_enabled" {
  description = "Includes the permissions to scan S3 buckets in the single policy document (json output)"
  type        = bool
  default     = true
}
