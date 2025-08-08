variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions"
  type        = string
  default     = ""
}
