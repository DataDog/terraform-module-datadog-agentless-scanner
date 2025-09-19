# Agentless Scanner Service Account Module

This module creates a Google Cloud service account for the Datadog Agentless Scanner instances with the necessary permissions to create, attach, and manage disks for scanning operations.

## Overview

The module creates:
- A service account for scanner instances to use
- Custom IAM roles with minimal required permissions for disk operations
- IAM bindings to allow the service account to perform scanning operations
- Access to Secret Manager for retrieving the Datadog API key
- Conditional access policies to restrict operations to scanner-created resources

## Usage

```hcl
module "agentless_scanner_service_account" {
  source = "./modules/agentless-scanner-service-account"

  api_key_secret_id = "datadog-api-key-secret"
  unique_suffix     = "abc123"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.attach_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.zone_operations](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.attach_disk_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.zone_operations_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.scanner_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.scanner_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.self_impersonation_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | Name of the Secret Manager secret containing the Datadog API key | `string` | n/a | yes |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to append to resource names to avoid collisions | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_scanner_service_account"></a> [scanner\_service\_account](#output\_scanner\_service\_account) | The scanner service account |
| <a name="output_scanner_service_account_email"></a> [scanner\_service\_account\_email](#output\_scanner\_service\_account\_email) | Email of the scanner service account |
| <a name="output_scanner_service_account_name"></a> [scanner\_service\_account\_name](#output\_scanner\_service\_account\_name) | Name of the scanner service account |
<!-- END_TF_DOCS -->