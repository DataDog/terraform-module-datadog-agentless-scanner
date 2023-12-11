variable "api_key" {
  description = "Specifies the API keys required by the Datadog Agent to submit vulnerabilities to Datadog."
  type        = string
}

variable "site" {
  description = "By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/"
  type        = string
  default     = "datadoghq.com"
}

variable "sidescanner_version" {
  description = "Specifies the side-scanner version installed"
  type        = string
  default     = "50.0~rc.5~side~scanner~2023120801-1"
}

variable "instance_profile_name" {
  description = "value"
  type        = string
}
