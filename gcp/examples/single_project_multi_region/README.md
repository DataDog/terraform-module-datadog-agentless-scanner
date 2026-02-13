# Single Project, Multi-Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy Datadog Agentless scanners in **multiple regions** within a single GCP project.

With this deployment, scanner instances are deployed in US (`us-central1`) and EU (`europe-west1`) regions, reducing cross-region data transfer costs when your resources are spread across regions.

**Note**: The regions are configured via the Google provider aliases in `main.tf`. This example uses `us-central1` and `europe-west1`, but you can change them to any GCP regions by editing the `region` fields in the `provider "google"` blocks.

## Architecture

The module deploys:
- Scanner instances in US (`us-central1`) and EU (`europe-west1`)
- Separate VPC network per region
- Cloud Router and Cloud NAT per region for outbound connectivity
- Service accounts for scanning within the same project

## Prerequisites

- Your GCP project must be [onboarded in your Datadog organization](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp) before deploying this module.
- GCP project with the following APIs enabled:
  - Compute Engine API
  - IAM Service Account Credentials API
  - Secret Manager API
- Datadog API key, APP key, and site value — in the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, choose **Terraform**, then copy from steps 2-4
- Appropriate GCP permissions to create VPCs, compute instances, and service accounts

## Quick start

To deploy Datadog Agentless scanners in multiple regions:

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

1. **Deploy the scanners**:

   > **Note**: Use the [Datadog site](https://docs.datadoghq.com/getting_started/site/) value from step 4 of the installation modal (e.g., `datadoghq.com`, `datadoghq.eu`, `us5.datadoghq.com`).

   ```sh
   terraform apply \
     -var="project_id=<my-gcp-project>" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_app_key=$DD_APP_KEY" \
     -var="datadog_site=<datadog-site>"
   ```

1. **Verify the deployment**:

   **Check GCP (immediate):** Confirm scanner instances are running in both regions:
   ```sh
   gcloud compute instances list --filter="labels.datadogagentlessscanner=true" --project=<my-gcp-project>
   ```
   You should see instances in both `us-central1` and `europe-west1` zones with status `RUNNING`. Instance health checks may take up to 5 minutes to pass.

   **Check Datadog (allow 15-30 minutes):** Go to the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp) and find your GCP project. You should see **Agentless Scanning** enabled with a green check next to vulnerability management. First scan results typically appear within 15-30 minutes.

   If scan results do not appear after 30 minutes, see [Troubleshooting](../README.md#troubleshooting).

### API Key Configuration

By default, this example passes the Datadog API key directly via `api_key`. The module stores it in Google Secret Manager automatically.

To reference a **pre-existing** Secret Manager secret instead, modify both module blocks in `main.tf`:

```hcl
module "datadog_agentless_scanner_us" {
  # ...
  api_key_secret_id = "projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
  # Remove the api_key argument when using api_key_secret_id
}

module "datadog_agentless_scanner_eu" {
  # ...
  api_key_secret_id = "projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
  # Remove the api_key argument when using api_key_secret_id
}
```

> **Note**: The `datadog_api_key` variable is still required even when using `api_key_secret_id`, because the Datadog Terraform provider needs it to call the Datadog API.

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
