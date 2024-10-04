## Description

The agentless-scanner-role module creates the proper role and policies for the agentless scanner instance to be able to assume the scanning delegate roles.

It exports the role and instance profile that should be attached to the agentless scanner instance.

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
| [aws_iam_instance_profile.profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.scanner_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanner_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_roles"></a> [account\_roles](#input\_account\_roles) | List of cross accounts roles ARN that the Datadog agentless scanner can assume - make sure to respect the same naming convention as the agentless scanner role. | `list(string)` | <pre>[<br>  "arn:*:iam::*:role/DatadogAgentlessScannerDelegateRole"<br>]</pre> | no |
| <a name="input_api_key_secret_arns"></a> [api\_key\_secret\_arns](#input\_api\_key\_secret\_arns) | List of ARNs of the secrets holding the Datadog API keys | `list(string)` | n/a | yes |
| <a name="input_api_key_secret_kms_key_arns"></a> [api\_key\_secret\_kms\_key\_arns](#input\_api\_key\_secret\_kms\_key\_arns) | List of ARNs of the KMS keys encrypting the secrets | `list(string)` | `[]` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Whether to enable AWS SSM to facilitate executing troubleshooting commands on the instance | `bool` | `false` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name to use on IAM policy created | `string` | `"DatadogAgentlessScannerAgentPolicy"` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | IAM policy path | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `"DatadogAgentlessScannerAgentRole"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `"/"` | no |
| <a name="input_organization_unit_ids"></a> [organization\_unit\_ids](#input\_organization\_unit\_ids) | List of AWS Organization Unit IDs that are allowed to assume the Datadog agentless scanner role | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile"></a> [instance\_profile](#output\_instance\_profile) | The Datadog agentless scanner instance profile created |
| <a name="output_role"></a> [role](#output\_role) | The Datadog agentless scanner role created |
<!-- END_TF_DOCS -->
