variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
  nullable    = false
}

variable "admin_ssh_key" {
  description = "SSH public key of the admin user"
  type        = string
}

variable "api_key" {
  description = "Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog"
  type        = string
  sensitive   = true
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = null
}

variable "location" {
  description = "The location where the Datadog Agentless Scanner resources will be created"
  type        = string
  nullable    = false
}

variable "bastion" {
  description = "Create a bastion in the subnet"
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "A map of additional tags to add to the resources created"
  type        = map(string)
  default     = {}
}
