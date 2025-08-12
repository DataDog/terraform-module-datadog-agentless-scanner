variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "datadog-agentless-scanner"
}

variable "unique_suffix" {
  description = "Unique suffix to append to resource names to avoid collisions"
  type        = string
  default     = ""
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_ssh" {
  description = "Whether to enable SSH firewall rule"
  type        = bool
  default     = true
}
