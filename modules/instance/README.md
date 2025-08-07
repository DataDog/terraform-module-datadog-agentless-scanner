## Description

The instance module can be used to spawn a dedicated instance specifically crafted for running the agentless scanner.

It creates an auto scaling group with a launch template that installs the agentless scanner on the instance.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.default_scanner_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_size"></a> [asg\_size](#input\_asg\_size) | Default size of the autoscaling group the instance is in (i.e. default number of instances to run) | `number` | `1` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile | `string` | n/a | yes |
| <a name="input_instance_image_id"></a> [instance\_image\_id](#input\_instance\_image\_id) | The Image ID (aka. AMI) used as baseline for the instance - SSM parameter path is allowed | `string` | `"resolve:ssm:/aws/service/canonical/ubuntu/server-minimal/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"` | no |
| <a name="input_instance_root_volume_size"></a> [instance\_root\_volume\_size](#input\_instance\_root\_volume\_size) | The instance root volume size in GiB | `number` | `30` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance | `string` | `"t4g.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource | `string` | `null` | no |
| <a name="input_max_asg_size"></a> [max\_asg\_size](#input\_max\_asg\_size) | Maximum size of the autoscaling group the instance is in (i.e. maximum number of instances to run) | `number` | `50` | no |
| <a name="input_min_asg_size"></a> [min\_asg\_size](#input\_min\_asg\_size) | Minimum size of the autoscaling group the instance is in (i.e. minimum number of instances to run) | `number` | `0` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix to be used on EC2 instance created | `string` | `"DatadogAgentlessScanner"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The VPC Subnet IDs to launch in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the instance/volume created | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID to launch in | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate with | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg"></a> [asg](#output\_asg) | The Auto Scaling group of the Agentless Scanner |
<!-- END_TF_DOCS -->
