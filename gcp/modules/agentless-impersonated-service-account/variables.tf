variable "scanner_service_account_email" {
  description = "Email of the scanner service account that impersonates this service account"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions"
  type        = string
  default     = ""
}
