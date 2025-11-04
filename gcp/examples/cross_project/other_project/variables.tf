variable "scanned_project_id" {
  description = "The GCP project ID that will be scanned by the Agentless scanner"
  type        = string
}

variable "scanner_service_account_email_us" {
  description = "Email of the US scanner service account from the scanner project (output from scanner_project deployment)"
  type        = string
}

variable "scanner_service_account_email_eu" {
  description = "Email of the EU scanner service account from the scanner project (output from scanner_project deployment)"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names. Must be alphanumeric only and maximum 6 characters (will be appended with region suffix)."
  type        = string
  default     = ""
}
