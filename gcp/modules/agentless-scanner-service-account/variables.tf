variable "project_id" {
  description = "The ID of the project in which to create the resources"
  type        = string
}

variable "impersonated_service_account_name" {
  description = "Name of the impersonated service account to grant impersonation access to"
  type        = string
}
