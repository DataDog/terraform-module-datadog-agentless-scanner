## Description

The agentless-scanning-policy module creates the IAM managed policy holding all the permissions required to perform agentless scans (snapshot creation and cleanup, EBS direct APIs, Lambda and ECR images, and optionally S3 objects), and attaches it to the given IAM role.

It is used:
- by the [scanning-delegate-role](../scanning-delegate-role/) module (self-hosted mode), to attach the policy to the delegate role assumed by the scanners.
- directly in SaaS mode, to attach the policy to the Datadog integration role. Datadog then performs the scans from its own infrastructure by assuming that role, and no scanner infrastructure is deployed in your account:

```hcl
module "agentless_scanning_policy" {
  source    = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanning-policy"
  role_name = var.datadog_integration_role
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
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
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.scanning_orchestrator_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_dspm_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policy_name_prefix"></a> [policy\_name\_prefix](#input\_policy\_name\_prefix) | Name prefix of the IAM policy created | `string` | `"DatadogAgentlessScanningPolicy"` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | IAM policy path | `string` | `"/"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role to attach the scanning policy to | `string` | n/a | yes |
| <a name="input_sensitive_data_scanning_enabled"></a> [sensitive\_data\_scanning\_enabled](#input\_sensitive\_data\_scanning\_enabled) | Installs specific permissions to enable scanning of S3 buckets | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy"></a> [policy](#output\_policy) | The customer managed policy granting Agentless Scanning permissions |
<!-- END_TF_DOCS -->
