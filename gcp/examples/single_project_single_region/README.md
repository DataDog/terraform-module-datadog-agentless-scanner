# Single Project, Single Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy a Datadog Agentless scanner in your [GCP](https://cloud.google.com/) project.

With this deployment, a single Agentless scanner is deployed in a single region with instances distributed across multiple zones for high availability.

> **Note**: This is the simplest deployment model and is ideal for evaluation or getting started. For production environments with multiple projects, see [multi_project_multi_region](../multi_project_multi_region/).

**Note**: The region is configured via the Google provider. In this example, `us-central1` is used, but you can change it to any GCP region by editing the `region` field in the `provider "google"` block in `main.tf`.

## Architecture

This example deploys:
- A Secret Manager secret containing the Datadog API key
- Two service accounts (via dedicated submodules):
  - Scanner service account (attached to instances)
  - Impersonated service account (for resource scanning)
- Scanner infrastructure (via the main GCP module):
  - Managed Instance Group (MIG) with scanner instances distributed across zones
  - VPC network with private subnet in the configured region
  - Cloud Router and Cloud NAT for outbound connectivity

## Prerequisites

- Your GCP project must be [onboarded in your Datadog organization](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp) before deploying this module.
- GCP project with the following APIs enabled:
  - Compute Engine API
  - IAM Service Account Credentials API
  - Secret Manager API
- Datadog API key, APP key, and site value — in the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, choose **Terraform**, then copy from steps 2-4
- Appropriate GCP permissions to create VPCs, compute instances, and service accounts

## Quick start

To deploy a Datadog Agentless scanner:

1. **Set your Datadog credentials** as environment variables. In the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, and choose **Terraform**. Copy your API key (step 2), APP key (step 3), and note your Datadog site (step 4). Set the keys as environment variables:
   ```sh
   export DD_API_KEY=<your-api-key>
   export DD_APP_KEY=<your-app-key>
   ```

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

1. **Deploy the scanner**:

   > **Note**: Use the [Datadog site](https://docs.datadoghq.com/getting_started/site/) value from step 4 of the installation modal (e.g., `datadoghq.com`, `datadoghq.eu`, `us5.datadoghq.com`).

   ```sh
   terraform apply \
     -var="project_id=<my-gcp-project>" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_app_key=$DD_APP_KEY" \
     -var="datadog_site=<datadog-site>"
   ```

1. **Verify the deployment**:

   **Check GCP (immediate):** Confirm scanner instances are running:
   ```sh
   gcloud compute instances list --filter="labels.datadogagentlessscanner=true" --project=<my-gcp-project>
   ```
   You should see instances with status `RUNNING`. Instance health checks may take up to 5 minutes to pass.

   **Check Datadog (allow 15-30 minutes):** Go to the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp) and find your GCP project. You should see **Agentless Scanning** enabled with a green check next to vulnerability management. First scan results typically appear within 15-30 minutes.

   If scan results do not appear after 30 minutes, see [Troubleshooting](../README.md#troubleshooting).

### API Key Configuration

This example creates a Secret Manager secret from the `datadog_api_key` variable and passes its ID to both the scanner service account module and the main scanner module via `api_key_secret_id`.

To reference a **pre-existing** Secret Manager secret instead, remove the `google_secret_manager_secret` and `google_secret_manager_secret_version` resources from `main.tf` and update the module references:

```hcl
module "scanner_service_account" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-scanner-service-account?ref=0.12.1"

  api_key_secret_id = "projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
}

module "impersonated_service_account" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp/modules/agentless-impersonated-service-account?ref=0.12.1"

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
}

module "datadog_agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp?ref=0.12.1"

  scanner_service_account_email = module.scanner_service_account.scanner_service_account_email
  api_key_secret_id             = "projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
  site                          = var.datadog_site
  vpc_name                      = "datadog-agentless-scanner"
}
```

> **Note**: The `datadog_api_key` variable is still required even when using a pre-existing secret, because the Datadog Terraform provider needs it to call the Datadog API.

## Cleanup

To remove all resources:
```sh
terraform destroy \
  -var="project_id=<my-gcp-project>" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=<datadog-site>"
```

## Troubleshooting

See the [Troubleshooting section](../README.md#troubleshooting) for common issues and debugging commands.
