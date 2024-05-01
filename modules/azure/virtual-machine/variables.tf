variable "name" {
  description = "Name prefix to be used on EC2 instance created"
  type        = string
  default     = "DatadogAgentlessScanner"
}

variable "location" {
  description = "The location of the resource group where the Datadog Agentless Scanner network resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Datadog Agentless Scanner network resources will be created"
  type        = string
}

variable "instance_size" {
  description = "The type of instance"
  type        = string
  default     = "Standard_B2ps_v2"
}

variable "instance_root_volume_size" {
  description = "The instance root volume size in GiB"
  type        = number
  default     = 30
}

variable "custom_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet to launch in"
  type        = string
}

variable "admin_username" {
  description = "Name of the admin user to use for the instance"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "SSH public key for the admin user"
  type        = string
  nullable    = false
}

variable "instance_count" {
  description = "Size of the autoscaling group the instance is in (i.e. number of instances to run)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of additional tags to add to the instance/volume created"
  type        = map(string)
  default     = {}
}

variable "user_assigned_identity" {
  description = "The resource ID of the managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances"
  type        = string
}
