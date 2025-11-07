# Single Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy a Datadog Agentless scanner in your [GCP](https://cloud.google.com/) project.

With this deployment, a single Agentless scanner is deployed in a single region with instances distributed across multiple zones for high availability. Datadog recommends this option for most use cases.

**Note**: The region is configured via the Google provider. In this example, `us-central1` is used, but you can change it to any GCP region.

## Architecture

The module deploys:
- VPC network with private subnet in the configured region
- Cloud Router and Cloud NAT for outbound connectivity
- Managed Instance Group (MIG) with scanner instances distributed across zones
- Two service accounts:
  - Scanner service account (attached to instances)
  - Impersonated service account (for resource scanning)

## Quick start

To deploy a Datadog agentless scanner:

1. **Configure your GCP project**:
   ```sh
   gcloud config set project <my-gcp-project>
   ```

1. **Authenticate with GCP**:
   ```sh
   gcloud auth application-default login
   ```

1. **Initialize Terraform**:
   ```sh
   terraform init
   ```

1. **Deploy the scanner**. You will need to:
   - Set your GCP project ID
   - Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/)
   - Set your Datadog site

   ```sh
   terraform apply \
     -var="project_id=my-gcp-project" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

## Prerequisites

- GCP project with the following APIs enabled:
  - Compute Engine API
  - IAM Service Account Credentials API
  - Secret Manager API
- Datadog API key with Remote Configuration enabled
- Appropriate GCP permissions to create VPCs, compute instances, and service accounts

### API Key Configuration

You have two options for providing the Datadog API key:

1. **Pass the API key directly** (shown in examples below):
   ```bash
   -var="datadog_api_key=$DD_API_KEY"
   ```

2. **Use Google Secret Manager** (recommended for production):
   - Create a secret in Google Secret Manager containing your Datadog API key
   - Use the secret ID instead:
   ```bash
   -var="api_key_secret_id=projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
   ```
   - The module will retrieve the API key from Secret Manager
   - Note: When using `api_key_secret_id`, omit the `datadog_api_key` variable

## Cleanup

To remove all resources:
```sh
terraform destroy
```

