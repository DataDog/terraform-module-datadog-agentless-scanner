variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions"
  type        = string
  default     = ""
}

variable "api_key_secret_id" {
  description = "Name of the Secret Manager secret containing the Datadog API key"
  type        = string
}
