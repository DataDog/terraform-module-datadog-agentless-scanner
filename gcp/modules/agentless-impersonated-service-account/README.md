# Agentless Impersonated Service Account Module

This module creates a Google Cloud service account that can be impersonated by the Datadog Agentless Scanner to access and scan disk resources within your GCP project.

## Overview

The module creates:
- A service account for disk scanning operations
- Custom IAM roles with minimal required permissions for disk access
- IAM bindings to allow the scanner service account to impersonate this target service account
- Conditional access policies to limit scanner access to only its own created snapshots

## Usage

```hcl
module "agentless_impersonated_service_account" {
  source = "./modules/agentless-impersonated-service-account"

  scanner_service_account_email = "scanner-sa@project.iam.gserviceaccount.com"
  unique_suffix                 = "abc123"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
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
| [google_project_iam_custom_role.create_snapshot](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.snapshot_readonly_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.agentless_artifactregistry_role_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.agentless_role_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.agentless_use_snapshot_role_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.target_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.impersonation_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scanner_service_account_email"></a> [scanner\_service\_account\_email](#input\_scanner\_service\_account\_email) | Email of the scanner service account that impersonates this service account | `string` | n/a | yes |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to append to resource names to avoid collisions | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The service account to be impersonated by Datadog Agentless Scanner for reading disk information |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the target service account |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Name of the target service account |
<!-- END_TF_DOCS -->