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
  description = "Datadog API key. Either api_key or api_key_secret_id must be provided, but not both."
  type        = string
  default     = null
  sensitive   = true
}

variable "site" {
  description = "The Datadog site of your organization where scanner data will be sent (for example, datadoghq.com, datadoghq.eu, us5.datadoghq.com). See https://docs.datadoghq.com/getting_started/site/"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "Username for SSH access"
  type        = string
  default     = null
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

variable "scanner_configuration" {
  description = "Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner. Warning: this is an advanced feature and can break the scanner if not used correctly."
  type        = any
  default     = {}
  validation {
    condition     = can(yamlencode(var.scanner_configuration))
    error_message = "The scanner_configuration variable cannot be properly encoded to YAML."
  }
  validation {
    condition     = !contains(keys(var.scanner_configuration), "api_key") && !contains(keys(var.scanner_configuration), "hostname") && !contains(keys(var.scanner_configuration), "site")
    error_message = "The scanner_configuration cannot override the 'api_key', 'hostname', or 'site' fields."
  }
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent. For more details: https://docs.datadoghq.com/agent/configuration/agent-configuration-files/. Warning: this is an advanced feature and can break the Datadog Agent if not used correctly."
  type        = any
  default     = {}
  validation {
    condition     = can(yamlencode(var.agent_configuration))
    error_message = "The agent_configuration variable cannot be properly encoded to YAML."
  }
  validation {
    condition     = !contains(keys(var.agent_configuration), "api_key") && !contains(keys(var.agent_configuration), "hostname") && !contains(keys(var.agent_configuration), "site") && !contains(keys(var.agent_configuration), "logs_enabled") && !contains(keys(var.agent_configuration), "ec2_prefer_imdsv2")
    error_message = "The agent_configuration cannot override the 'api_key', 'hostname', or 'site' fields."
  }
}

variable "api_key_secret_id" {
  description = "Identifier of the Secret Manager secret containing the Datadog API key in the format projects/[project_id]/secrets/[secret_name]"
  type        = string
  default     = null
  validation {
    condition     = var.api_key_secret_id == null || can(regex("^projects/[a-zA-Z0-9-]+/secrets/[a-zA-Z0-9-]+$", var.api_key_secret_id))
    error_message = "The ID must be in the format 'projects/[project_id]/secrets/[secret_name]'."
  }
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
