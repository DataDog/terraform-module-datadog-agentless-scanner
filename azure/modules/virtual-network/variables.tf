variable "location" {
  description = "The location of the resource group where the Datadog Agentless Scanner network resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner network resources will be created"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bastion" {
  description = "Create a bastion in the subnet"
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "A map of additional tags to add to the network resources created"
  type        = map(string)
  default     = {}
}
