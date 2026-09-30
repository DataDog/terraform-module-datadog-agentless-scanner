## Description

The agentless-scanning-policy module provides the IAM policy document holding all the permissions required to perform agentless scans (snapshot creation and cleanup, EBS direct APIs, Lambda and ECR images, and optionally S3 objects). It does not create any resource: use its `json` output in a customer managed policy attached to the role performing the scans.

It is used:
- by the [scanning-delegate-role](../scanning-delegate-role/) module (self-hosted mode), on the delegate role assumed by the scanners.
- directly in SaaS mode, on the Datadog integration role. Datadog then performs the scans from its own infrastructure by assuming that role, and no scanner infrastructure is deployed in your account. See the [SaaS example](../../examples/saas/).

Use a managed policy (`aws_iam_policy`) rather than an inline one: the document is close to the size limit of inline policies on a role, and Datadog needs the ARN of the policy.

```hcl
module "agentless_scanning_policy" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanning-policy"
}

resource "aws_iam_policy" "agentless_scanning" {
  name_prefix = "DatadogAgentlessScanningPolicy"
  policy      = module.agentless_scanning_policy.json
}

resource "aws_iam_role_policy_attachment" "agentless_scanning" {
  role       = var.datadog_integration_role
  policy_arn = aws_iam_policy.agentless_scanning.arn
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
| [aws_iam_policy_document.scanning_orchestrator_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_dspm_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sensitive_data_scanning_enabled"></a> [sensitive\_data\_scanning\_enabled](#input\_sensitive\_data\_scanning\_enabled) | Includes specific permissions to enable scanning of S3 buckets | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | The IAM policy document granting Agentless Scanning permissions, to be used in a customer managed policy |
<!-- END_TF_DOCS -->
