# Agentless Scanner Service Account Module

This module creates the service account used by Datadog Agentless Scanner compute instances and sets up the necessary impersonation binding.

## Resources Created

- **Service Account**: Service account attached to compute instances running the agentless scanner
- **IAM Binding**: Grants the compute instance service account permission to impersonate the disk reader service account

## Functionality

The compute instance service account is granted the `roles/iam.serviceAccountTokenCreator` role on the disk reader service account, allowing it to:
- Impersonate the disk reader service account
- Use the disk reader's permissions to scan disk and snapshot information
- Maintain separation of concerns between compute and disk access permissions

## Usage

```hcl
module "agentless_scanner_service_account" {
  source = "./modules/agentless-scanner-service-account"

  project_id                         = var.project_id
  disk_reader_service_account_name   = module.agentless_impersonated_service_account.disk_reader_service_account_name
}
```

## Requirements

- Google Cloud IAM API must be enabled
- Disk reader service account must exist (created by agentless-impersonated-service-account module)
- Sufficient permissions to create service accounts and IAM bindings in the project 