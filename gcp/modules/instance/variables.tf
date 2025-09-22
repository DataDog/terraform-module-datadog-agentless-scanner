variable "zones" {
  description = "List of zones to deploy resources across"
  type        = list(string)
}

variable "network_name" {
  description = "The name of the network"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork"
  type        = string
}

variable "service_account_email" {
  description = "Email of the service account to attach to instances"
  type        = string
}

variable "api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "site" {
  description = "The site of your Datadog account. Choose from: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1). See https://docs.datadoghq.com/getting_started/site/"
  type        = string

  validation {
    condition = contains([
      "datadoghq.com",
      "us3.datadoghq.com",
      "us5.datadoghq.com",
      "datadoghq.eu",
      "ap1.datadoghq.com"
    ], var.site)
    error_message = "The site must be one of: datadoghq.com (US1), us3.datadoghq.com (US3), us5.datadoghq.com (US5), datadoghq.eu (EU1), ap1.datadoghq.com (AP1)."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "Username for SSH access"
  type        = string
}

variable "instance_count" {
  description = "Number of instances in the managed instance group"
  type        = number
  default     = 1
}

variable "scanner_version" {
  description = "Specifies the version of the scanner to install"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)."
  }
}

variable "scanner_channel" {
  description = "Specifies the channel to use for installing the scanner"
  type        = string
  validation {
    condition     = contains(["stable", "beta", "nightly"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable', 'beta' or 'nightly'."
  }
}

variable "scanner_repository" {
  description = "Repository URL to install the scanner from."
  type        = string
  validation {
    condition     = can(regex("^https://", var.scanner_repository))
    error_message = "The scanner repository must be a valid HTTPs URL."
  }
}

variable "api_key_secret_id" {
  description = "Identifier of the pre-provisioned Secret Manager secret containing the Datadog API key"
  type        = string
  default     = null
  validation {
    condition     = var.api_key_secret_id == null || can(regex("^projects/[a-zA-Z0-9-]+/secrets/[a-zA-Z0-9-]+$", var.api_key_secret_id))
    error_message = "The ID must be in the format 'projects/[project_id]/secrets/[secret_name]'."
  }
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions"
  type        = string
  default     = ""
}
