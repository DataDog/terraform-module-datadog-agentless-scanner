## Description

The scanning-delegate-role module creates the proper role and policies to allow the agentless scanner to interact with AWS services of a specific account.

It should be installed in every account that the agentless scanner will scan.

### Note on AWS Service control policies (SCPs)

Some permissions required by the Datadog Agentless Scanner may conflict with
organizational policies enforced by SCPs. For instance, a scanner will require
`ec2:DescribeSnapshots`, `ec2:DescribeVolumes`, `ec2:CreateSnapshot` and
`ec2:DeleteSnapshot`. If any of these permissions is globally restricted by an
SCP at the organization level, the scanner will not be able to perform its scans
properly.

In such case you should see error or warning logs in the Datadog logs from the
`service:agentless-scanner`, of the form:

```
... User: arn:aws:sts::<account>:assumed-role/DatadogAgentlessScannerDelegateRole/DatadogAgentlessScanner is not authorized to perform: ec2:DescribeSnapshots with an explicit deny in a service control policy.
```

For more details on how to adjust you SCPs, please refer to the AWS
documentation on [Service Control
Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html).

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
| [aws_iam_policy.rds_service_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanning_orchestrator_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanning_rds_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanning_worker_dspm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanning_worker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.rds_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.delegate_role_rds_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.orchestrator_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.rds_service_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.workers_dspm_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_service_role_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_service_role_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_orchestrator_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_rds_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_dspm_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `"DatadogAgentlessScannerDelegateRole"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role and policies path | `string` | `"/"` | no |
| <a name="input_scanner_organizational_unit_ids"></a> [scanner\_organizational\_unit\_ids](#input\_scanner\_organizational\_unit\_ids) | List of AWS Organizations organizational units (OUs) allowed to assume this role | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_scanner_roles"></a> [scanner\_roles](#input\_scanner\_roles) | List of roles ARN allowed to assume this role | `list(string)` | n/a | yes |
| <a name="input_sensitive_data_scanning_enabled"></a> [sensitive\_data\_scanning\_enabled](#input\_sensitive\_data\_scanning\_enabled) | Installs specific permissions to enable scanning of S3 buckets | `bool` | `false` | no |
| <a name="input_sensitive_data_scanning_rds_enabled"></a> [sensitive\_data\_scanning\_rds\_enabled](#input\_sensitive\_data\_scanning\_rds\_enabled) | Installs specific permissions to enable scanning of RDS databases | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_service_role_arn"></a> [rds\_service\_role\_arn](#output\_rds\_service\_role\_arn) | The ARN of the service role used by RDS to write the export to the S3 bucket |
| <a name="output_role"></a> [role](#output\_role) | The scanning role created |
<!-- END_TF_DOCS -->
