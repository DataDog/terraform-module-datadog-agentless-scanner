variable "name" {
  description = "The name of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
  default     = "DatatogAgentlessScanner"
}

variable "location" {
  description = "The location of the resource group where the Datadog Agentless Scanner resources will be created"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to add to the resource group"
  type        = map(string)
  default     = {}
}
