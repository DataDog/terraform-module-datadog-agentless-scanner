# Agentless Impersonated Service Account Module

This module creates the IAM resources needed for Datadog Agentless Scanner to read disk information in Google Cloud Platform.

## Resources Created

- **Custom IAM Role**: A custom role with permissions to read disk and snapshot information
- **Service Account**: A service account for reading disk information
- **IAM Binding**: Binds the custom role to the service account

## Permissions Included

The custom role includes the following permissions:
- `compute.disks.get`
- `compute.disks.list`  
- `compute.snapshots.get`
- `compute.snapshots.list`
- `compute.diskTypes.get`
- `compute.diskTypes.list`

## Usage

```hcl
module "agentless_impersonated_service_account" {
  source = "./modules/agentless-impersonated-service-account"

  project_id = var.project_id
}
```

## Requirements

- Google Cloud IAM API must be enabled
- Sufficient permissions to create custom roles and service accounts in the project 