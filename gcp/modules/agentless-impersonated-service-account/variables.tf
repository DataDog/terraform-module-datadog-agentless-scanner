variable "scanner_service_account_email" {
  description = "Email of the scanner service account that impersonates this service account"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions. Must be alphanumeric only (no hyphens or underscores) and maximum 8 characters. If not provided, a random suffix is generated."
  type        = string
  default     = ""
  validation {
    condition     = var.unique_suffix == "" || (can(regex("^[a-zA-Z0-9]+$", var.unique_suffix)) && length(var.unique_suffix) <= 8)
    error_message = "The unique_suffix must contain only alphanumeric characters (letters and numbers, no hyphens or underscores) and be maximum 8 characters long."
  }
}
