## Description
This module creates the Agentless S3 Bucket which is used during the scan of the RDS databases exports.

Along with the bucket, it also creates a KMS replica key to encrypt the exported data,
and a bucket policy to allow the RDS service role to write to the bucket and 
the Agentless Scanner Delegate role to read from the bucket.

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
| [aws_kms_replica_key.replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.bucket_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.bucket_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.bucket_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_iam_policy_document.bucket_access_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_delegate_role_arn"></a> [iam\_delegate\_role\_arn](#input\_iam\_delegate\_role\_arn) | The ARN of the Agentless Scanner Delegate role | `string` | n/a | yes |
| <a name="input_primary_kms_key_arn"></a> [primary\_kms\_key\_arn](#input\_primary\_kms\_key\_arn) | Primary KMS key ARN to encrypt the exported data | `string` | n/a | yes |
| <a name="input_primary_kms_key_region"></a> [primary\_kms\_key\_region](#input\_primary\_kms\_key\_region) | The region of the primary KMS key | `string` | n/a | yes |
| <a name="input_rds_service_role_arn"></a> [rds\_service\_role\_arn](#input\_rds\_service\_role\_arn) | The ARN of the service role used by RDS to write the export to the S3 bucket | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
