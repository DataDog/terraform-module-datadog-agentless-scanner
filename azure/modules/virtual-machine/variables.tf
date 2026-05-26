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
  description = <<-EOT
    The VM SKU to use for the scanner VMSS. When null (default), the module
    auto-selects from a 3-tier fallback chain based on what is available in
    the target region:
      1. Standard_B2ps_v2  (ARM Burstable, cheapest, major regions)
      2. Standard_D2pls_v6 (ARM v6 D-series, modern ARM-capable regions)
      3. Standard_D2as_v5  (AMD x86 D-series, universal fallback covering
                            2022+ regions like qatarcentral, uaenorth,
                            italynorth, spaincentral, etc.)
    Set this explicitly to bypass auto-selection. When overriding to an x86
    SKU, also set image_sku to a non-arm64 Ubuntu SKU (e.g. "minimal").
  EOT
  type        = string
  default     = null
}

variable "image_sku" {
  description = <<-EOT
    Ubuntu 24.04 LTS image SKU to use for the scanner VMSS. When null
    (default), the module picks "minimal-arm64" for ARM SKUs and "minimal"
    for x86 SKUs. Set explicitly to use a custom Ubuntu SKU; in that case
    you must also set instance_size to a matching architecture.
  EOT
  type        = string
  default     = null
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
  description = "Size of the scale set the scanner instance is in (i.e. number of instances to run)"
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
