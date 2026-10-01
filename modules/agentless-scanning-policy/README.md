## Description

The agentless-scanning-policy module provides the IAM policy document holding all the permissions required to perform agentless scans (snapshot creation and cleanup, EBS direct APIs, Lambda and ECR images, and optionally S3 objects). It does not create any resource: use its outputs in customer managed policies attached to the role performing the scans.

It is used:
- by the [scanning-delegate-role](../scanning-delegate-role/) module (self-hosted mode), which creates separate orchestrator, worker and DSPM policies from the `orchestrator_json`, `worker_json` and `dspm_json` outputs on the delegate role assumed by the scanners.
- directly in SaaS mode, where the `json` output merges all the permissions in a single document, used in one policy attached to the Datadog integration role. Datadog then performs the scans from its own infrastructure by assuming that role, and no scanner infrastructure is deployed in your account. See the [SaaS example](../../examples/saas/).

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
| [aws_iam_policy_document.scanning_orchestrator_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_dspm_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scanning_worker_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sensitive_data_scanning_enabled"></a> [sensitive\_data\_scanning\_enabled](#input\_sensitive\_data\_scanning\_enabled) | Includes the permissions to scan S3 buckets in the single policy document (json output) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dspm_json"></a> [dspm\_json](#output\_dspm\_json) | IAM policy document for the scanning of S3 buckets (self-hosted mode) |
| <a name="output_json"></a> [json](#output\_json) | Single IAM policy document granting all Agentless Scanning permissions (SaaS mode) |
| <a name="output_orchestrator_json"></a> [orchestrator\_json](#output\_orchestrator\_json) | IAM policy document for the scanning orchestrator (self-hosted mode) |
| <a name="output_worker_json"></a> [worker\_json](#output\_worker\_json) | IAM policy document for the scanning worker (self-hosted mode) |
<!-- END_TF_DOCS -->
