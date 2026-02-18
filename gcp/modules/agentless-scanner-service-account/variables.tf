variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions. Must be alphanumeric only (no hyphens or underscores) and maximum 8 characters. If not provided, a random suffix is generated."
  type        = string
  default     = ""
  validation {
    condition     = var.unique_suffix == "" || (can(regex("^[a-zA-Z0-9]+$", var.unique_suffix)) && length(var.unique_suffix) <= 8)
    error_message = "The unique_suffix must contain only alphanumeric characters (letters and numbers, no hyphens or underscores) and be maximum 8 characters long."
  }
}

variable "api_key_secret_ids" {
  description = "List of Secret Manager secret identifiers containing the Datadog API keys in the format projects/[project_id]/secrets/[secret_name]"
  type        = list(string)
  validation {
    condition     = alltrue([for id in var.api_key_secret_ids : can(regex("^projects/[a-zA-Z0-9-]+/secrets/[a-zA-Z0-9-]+$", id))])
    error_message = "Each ID must be in the format 'projects/[project_id]/secrets/[secret_name]'."
  }
}
