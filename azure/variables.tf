variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner resources will be created."
  type        = string
  nullable    = false
}

variable "admin_ssh_key" {
  description = "SSH public key of the admin user."
  type        = string
}

variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog."
  type        = string
  sensitive   = true
  default     = null
}

variable "api_key_secret_id" {
  description = "The versionless resource ID of the Azure Key Vault secret holding the Datadog API key. Ignored if api_key is specified."
  type        = string
  default     = null
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = null
}

variable "location" {
  description = "The location where the Datadog Agentless Scanner resources will be created."
  type        = string
  nullable    = false
}

variable "create_roles" {
  description = "Specifies whether to create the role definitions and assignments required to scan resources."
  type        = bool
  nullable    = false
  default     = true
}

variable "scan_scopes" {
  description = "The set of scopes that the Datadog Agentless Scanner is allowed to scan. Defaults to the current subscription."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "vnet_cidr" {
  description = "The CIDR block for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bastion" {
  description = "Create a bastion in the subnet."
  type        = bool
  default     = false
  nullable    = false
}

variable "instance_count" {
  description = "Size of the scale set the scanner instance is in (i.e. number of instances to run)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of additional tags to add to the resources created."
  type        = map(string)
  default     = {}
}

variable "scanner_version" {
  description = "Version of the scanner to install"
  type        = string
  default     = "0.11"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)"
  }
}

variable "scanner_channel" {
  description = "Channel of the scanner to install from (stable or beta)."
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta", "nightly"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable', 'beta' or 'nightly'"
  }
}

variable "scanner_repository" {
  description = "Repository URL to install the scanner from."
  type        = string
  default     = "https://apt.datadoghq.com/"
  validation {
    condition     = can(regex("^https://", var.scanner_repository))
    error_message = "The scanner repository must be a valid HTTPs URL"
  }
}

variable "scanner_configuration" {
  description = "Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner."
  type        = any
  default     = {}
}

variable "agent_configuration" {
  description = "Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent."
  type        = any
  default     = {}
}
