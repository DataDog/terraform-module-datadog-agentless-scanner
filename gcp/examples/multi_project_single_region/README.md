# Multi-Project, Single Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy a Datadog Agentless scanner in a dedicated GCP project and scan resources in **other GCP projects**, all within a single region.

With this deployment, scanner infrastructure is centralized in one project while scanning resources across your organization. This is the cross-project model simplified to a single region.

**Note**: The region is configured via the Google provider in `scanner_project/main.tf`. This example uses `us-central1`, but you can change it to any GCP region by editing the `region` field in the `provider "google"` block.

## Architecture

This example demonstrates:
- **Scanner Project**: Hosts the scanner infrastructure in a single region (`us-central1`)
- **Other Project(s)**: Projects to be scanned, with an impersonated service account for the scanner

```
┌─────────────────────────────────────────┐
│   Scanner Project                       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Region (us-central1)            │   │
│  │  - VPC & Scanner Instances      │   │
│  │  - Scanner Service Account      │   │
│  └─────────────────────────────────┘   │
└────────────┬────────────────────────────┘
             │
             │ impersonate
             │
┌────────────▼────────────────────────────┐
│   Other Project (repeatable)            │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ Impersonated SA                  │  │
│  └───────────┬──────────────────────┘  │
│              │ scan                     │
│  ┌───────────▼──────────────────────┐  │
│  │ Compute Resources                │  │
│  │ (Disks, Snapshots, etc.)         │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Prerequisites

- All GCP projects (scanner and scanned) must be [onboarded in your Datadog organization](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp) before deploying this module.
- Multiple GCP projects with appropriate permissions
- APIs enabled in all projects:
  - Compute Engine API
  - IAM Service Account Credentials API
  - Secret Manager API (scanner project only)
- Datadog API key, APP key, and site value — in the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, choose **Terraform**, then copy from steps 2-4
- Permissions to create service accounts and IAM bindings across projects

## Quick start

### Step 1: Deploy the Scanner Infrastructure

1. **Set your Datadog credentials** as environment variables. In the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, and choose **Terraform**. Copy your API key (step 2), APP key (step 3), and note your Datadog site (step 4). Set the keys as environment variables:
   ```sh
   export DD_API_KEY=<your-api-key>
   export DD_APP_KEY=<your-app-key>
   ```

1. **Configure your GCP project**:
   ```sh
   gcloud config set project <my-scanner-project>
   ```

1. **Authenticate with GCP**:
   ```sh
   gcloud auth application-default login
   ```

1. **Navigate to the scanner_project folder**:
   ```sh
   cd scanner_project
   ```

1. **Initialize Terraform**:
   ```sh
   terraform init
   ```

1. **Deploy the scanner infrastructure**:

   > **Note**: Use the [Datadog site](https://docs.datadoghq.com/getting_started/site/) value from step 4 of the installation modal (e.g., `datadoghq.com`, `datadoghq.eu`, `us5.datadoghq.com`).

   ```sh
   terraform apply \
     -var="scanner_project_id=<my-scanner-project>" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_app_key=$DD_APP_KEY" \
     -var="datadog_site=<datadog-site>"
   ```

1. **Verify scanner instances are running**:
   ```sh
   gcloud compute instances list --filter="labels.datadogagentlessscanner=true" --project=<my-scanner-project>
   ```
   You should see instances with status `RUNNING`. Health checks may take up to 5 minutes to pass.

1. **Save the output for the next step**:
   ```sh
   SCANNER_SA=$(terraform output -raw scanner_service_account_email)
   ```

### Step 2: Set up Other Projects for Scanning

> [!IMPORTANT]
> To scan multiple projects, create a **separate copy** of the `other_project` directory for each project (e.g., `other_project_teamA`, `other_project_teamB`). Each copy maintains its own Terraform state, preventing one project's resources from being destroyed when deploying another.

For each project you want to scan:

```sh
cp -r other_project other_project_<name>
cd other_project_<name>
terraform init
terraform apply \
  -var="scanned_project_id=<my-other-project>" \
  -var="scanner_service_account_email=$SCANNER_SA" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=<datadog-site>"
```

1. **Verify scanning in Datadog (allow 15-30 minutes)**:

   Go to the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp). For **each project** (the scanner project and every scanned project), you should see **Agentless Scanning** enabled with a green check next to vulnerability management. First scan results typically appear within 15-30 minutes.

   > **Note**: Check each scanned project individually. Running scanner instances do not guarantee that cross-project impersonation is working for every target project.

   If scan results do not appear after 30 minutes, see [Troubleshooting](../README.md#troubleshooting).

> **Tip**: To add more projects later, repeat Step 2 with a new copy of the `other_project` directory. The `$SCANNER_SA` value is the same for every scanned project. If you are in a new terminal session, retrieve it again with `cd scanner_project && terraform output -raw scanner_service_account_email`.

### API Key Configuration

By default, this example passes the Datadog API key directly via `api_key`. The module stores it in Google Secret Manager automatically.

To reference a **pre-existing** Secret Manager secret instead, modify the module block in `scanner_project/main.tf`:

```hcl
module "datadog_agentless_scanner" {
  # ...
  api_key_secret_id = "projects/YOUR_PROJECT/secrets/YOUR_SECRET_NAME"
  # Remove the api_key argument when using api_key_secret_id
}
```

> **Note**: The `datadog_api_key` variable is still required even when using `api_key_secret_id`, because the Datadog Terraform provider needs it to call the Datadog API.

## Cleanup

To remove all resources, destroy scanned projects first, then the scanner project. This order ensures the impersonated service accounts are removed before the scanner infrastructure they depend on.

```sh
# 1. In each other_project deployment
cd other_project_<name>
terraform destroy \
  -var="scanned_project_id=<my-other-project>" \
  -var="scanner_service_account_email=$SCANNER_SA" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=<datadog-site>"

# 2. In the scanner project (after all other_project deployments are destroyed)
cd ../scanner_project
terraform destroy \
  -var="scanner_project_id=<my-scanner-project>" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=<datadog-site>"
```

> **Note**: To remove a single scanned project while keeping others, only run `terraform destroy` in that project's directory (e.g., `other_project_teamA`). Each directory has independent Terraform state, so destroying one does not affect others.

## Troubleshooting

See the [Troubleshooting section](../README.md#troubleshooting) for common issues and debugging commands.
