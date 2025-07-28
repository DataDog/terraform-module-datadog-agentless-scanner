variable "project_id" {
  description = "The ID of the project in which to create the VM"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "Name prefix for VPC resources"
  type        = string
  default     = "datadog-agentless-scanner"
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

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of additional labels to add to resources"
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "The name of the network (deprecated - use vpc_name instead)"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "The name of the subnetwork (deprecated - use subnet_cidr instead)"
  type        = string
  default     = "default"
}

variable "api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "site" {
  description = "Datadog site (e.g., datadoghq.com, datadoghq.eu)"
  type        = string
  default     = "datadoghq.com"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "Username for SSH access"
  type        = string
  default     = "ubuntu"
}

variable "instance_count" {
  description = "Number of instances in the managed instance group"
  type        = number
  default     = 1
}

variable "scanner_version" {
  description = "Specifies the version of the scanner to install"
  type        = string
  default     = "0.11"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.scanner_version))
    error_message = "The scanner version must start with a number, followed by a period and a number (X.Y)."
  }
}

variable "scanner_channel" {
  description = "Specifies the channel to use for installing the scanner"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "beta", "nightly"], var.scanner_channel)
    error_message = "The scanner channel must be either 'stable', 'beta' or 'nightly'."
  }
}

variable "scanner_repository" {
  description = "Repository URL to install the scanner from."
  type        = string
  default     = "https://apt.datadoghq.com/"
  validation {
    condition     = can(regex("^https://", var.scanner_repository))
    error_message = "The scanner repository must be a valid HTTPs URL."
  }
}
