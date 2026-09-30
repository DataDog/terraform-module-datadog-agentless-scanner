## Description

The agentless-scanning-saas module sets up Agentless Scanning in SaaS mode: Datadog performs the scans from its own infrastructure by assuming the Datadog integration role, so no scanner infrastructure is deployed in your account. The module attaches the required scanning policy to the Datadog integration role.

It should be installed in every account to scan, instead of the scanning-delegate-role, agentless-scanner-role and scanner modules.

## How to use this module

```hcl
module "agentless_scanning_saas" {
  source                   = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanning-saas"
  datadog_integration_role = var.datadog_integration_role
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_scanning_policy"></a> [scanning\_policy](#module\_scanning\_policy) | ../agentless-scanning-policy | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datadog_integration_role"></a> [datadog\_integration\_role](#input\_datadog\_integration\_role) | Role name of the Datadog integration used to integrate the AWS account to Datadog. Datadog assumes this role to perform the scans. | `string` | n/a | yes |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | IAM policy path | `string` | `"/"` | no |
| <a name="input_sensitive_data_scanning_enabled"></a> [sensitive\_data\_scanning\_enabled](#input\_sensitive\_data\_scanning\_enabled) | Installs specific permissions to enable scanning of S3 buckets | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scanning_policy"></a> [scanning\_policy](#output\_scanning\_policy) | The customer managed policy attached to the Datadog integration role |
<!-- END_TF_DOCS -->
