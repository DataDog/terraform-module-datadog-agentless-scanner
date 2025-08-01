variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "datadog-agentless-scanner"
}

variable "region" {
  description = "The region to deploy VPC resources"
  type        = string
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
