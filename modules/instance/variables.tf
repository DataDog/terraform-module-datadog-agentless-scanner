variable "name" {
  description = "Name prefix to be used on EC2 instance created"
  type        = string
  default     = "DatadogAgentlessScanner"
}

variable "instance_type" {
  description = "The type of instance"
  type        = string
  default     = "t4g.large"
}

variable "instance_image_id" {
  description = "The Image ID (aka. AMI) used as baseline for the instance - SSM parameter path is allowed"
  type        = string
  default     = "resolve:ssm:/aws/service/canonical/ubuntu/server-minimal/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"
}

variable "instance_root_volume_size" {
  description = "The instance root volume size in GiB"
  type        = number
  default     = 30
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID to launch in"
  type        = string
}

variable "subnet_ids" {
  description = "The VPC Subnet IDs to launch in"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "min_asg_size" {
  description = "Minimum size of the autoscaling group the instance is in (i.e. minimum number of instances to run)"
  type        = number
  default     = 0
}

variable "max_asg_size" {
  description = "Maximum size of the autoscaling group the instance is in (i.e. maximum number of instances to run)"
  type        = number
  default     = 50
}

variable "asg_size" {
  description = "Default size of the autoscaling group the instance is in (i.e. default number of instances to run)"
  type        = number
  default     = 1
}



variable "tags" {
  description = "A map of additional tags to add to the instance/volume created"
  type        = map(string)
  default     = {}
}
