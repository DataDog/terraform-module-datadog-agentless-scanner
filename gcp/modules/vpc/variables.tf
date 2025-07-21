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

variable "secondary_ranges" {
  description = "Secondary IP ranges for the subnet"
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

variable "enable_nat" {
  description = "Whether to enable NAT Gateway for outbound internet access"
  type        = bool
  default     = true
}

variable "enable_ssh" {
  description = "Whether to enable SSH firewall rule"
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_http" {
  description = "Whether to enable HTTP/HTTPS firewall rules"
  type        = bool
  default     = false
}

variable "enable_private_service_connect" {
  description = "Whether to enable Private Service Connect for Google APIs"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of additional labels to add to resources"
  type        = map(string)
  default     = {}
} 
