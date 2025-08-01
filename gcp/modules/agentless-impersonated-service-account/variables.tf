variable "project_id" {
  description = "The ID of the project in which to create the resources"
  type        = string
}

variable "scanner_service_account_email" {
  description = "Email of the scanner service account that will impersonate this service account"
  type        = string
}
