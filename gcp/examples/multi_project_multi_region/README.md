# Multi-Project, Multi-Region Example (Recommended)

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy Datadog Agentless scanners across **multiple regions** in one GCP project, while scanning resources in **other GCP projects**.

This is the **recommended deployment model for production** that combines:
- Multi-region deployment for cost optimization (US and EU)
- Cross-project scanning for centralized management

> **Note**: For simpler setups, see the other [deployment playbooks](../README.md).

**Note**: The regions are configured via the Google provider aliases in `scanner_project/main.tf`. This example uses `us-central1` and `europe-west1`, but you can change them to any GCP regions by editing the `region` fields in the `provider "google"` blocks.

## Architecture

This example demonstrates:
- **Scanner Project**: Hosts the scanner infrastructure across multiple regions (`us-central1` and `europe-west1`)
- **Other Project(s)**: Projects to be scanned, with impersonated service accounts for each regional scanner

```
┌─────────────────────────────────────────┐
│   Scanner Project                       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ US Region (us-central1)         │   │
│  │  - VPC & Scanner Instances      │   │
│  │  - Scanner Service Account US   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ EU Region (europe-west1)        │   │
│  │  - VPC & Scanner Instances      │   │
│  │  - Scanner Service Account EU   │   │
│  └─────────────────────────────────┘   │
└────────────┬────────────┬───────────────┘
             │            │
             │ impersonate│
             │            │
┌────────────▼────────────▼───────────────┐
│   Other Project                         │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ Impersonated SA (US)             │  │
│  │ Impersonated SA (EU)             │  │
│  └───────────┬──────────────────────┘  │
│              │ scan                     │
│  ┌───────────▼──────────────────────┐  │
│  │ Compute Resources                │  │
│  │ (Disks, Snapshots, etc.)         │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## When to Use This Deployment

Use this deployment model when:
- You have multiple GCP projects to scan
- Your resources are distributed across multiple regions
- You want to minimize cross-region data transfer costs
- You need centralized scanner management

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

### Step 1: Deploy the Multi-Region Scanner Infrastructure

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

1. **Review the deployment plan**:

   > **Note**: Replace `datadoghq.com` with your [Datadog site](https://docs.datadoghq.com/getting_started/site/) if you use a different one (e.g., `datadoghq.eu`, `us5.datadoghq.com`). You can determine your site from the URL you use to log in to Datadog.

   ```sh
   terraform plan \
     -var="scanner_project_id=<my-scanner-project>" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_app_key=$DD_APP_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

1. **Deploy the scanner infrastructure**:
   ```sh
   terraform apply \
     -var="scanner_project_id=<my-scanner-project>" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_app_key=$DD_APP_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

1. **Verify scanner instances are running in both regions**:
   ```sh
   gcloud compute instances list --filter="labels.datadogagentlessscanner=true" --project=<my-scanner-project>
   ```
   You should see instances in both `us-central1` and `europe-west1` zones with status `RUNNING`. Health checks may take up to 5 minutes to pass.

1. **Save the outputs for the next step**:
   ```sh
   SCANNER_SA_US=$(terraform output -raw scanner_service_account_email_us)
   SCANNER_SA_EU=$(terraform output -raw scanner_service_account_email_eu)
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
  -var="scanner_service_account_email_us=$SCANNER_SA_US" \
  -var="scanner_service_account_email_eu=$SCANNER_SA_EU" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=datadoghq.com"
```

1. **Verify scanning in Datadog (allow 15-30 minutes)**:

   Go to the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp). For **each project** (the scanner project and every scanned project), you should see **Agentless Scanning** enabled with a green check next to vulnerability management. First scan results typically appear within 15-30 minutes.

   > **Note**: Check each scanned project individually. Running scanner instances do not guarantee that cross-project impersonation is working for every target project.

   If scan results do not appear after 30 minutes, see [Troubleshooting](../README.md#troubleshooting).

> **Tip**: To add more projects later, repeat Step 2 with a new copy of the `other_project` directory. The `$SCANNER_SA_US` and `$SCANNER_SA_EU` values are the same for every scanned project. If you are in a new terminal session, retrieve them again with `cd scanner_project && terraform output -raw scanner_service_account_email_us` and `terraform output -raw scanner_service_account_email_eu`.

## How It Works

1. **Scanner Project Setup**:
   - Creates VPC and compute infrastructure in US (`us-central1`) and EU (`europe-west1`)
   - Creates scanner service accounts for each region (attached to instances)
   - Creates impersonated service accounts for scanning resources in the scanner project itself

2. **Other Project Setup**:
   - Creates impersonated service accounts with read permissions on compute resources
   - Grants the scanner service accounts (from both US and EU) permission to impersonate these service accounts

3. **Scanning Process**:
   - Scanner instances use their service account to impersonate the target project's service account
   - The impersonated service account has permissions to read and scan resources
   - Regional scanners optimize costs by scanning resources in their local region when possible

## Regional Scanner Behavior

- **US Scanner** (`us-central1`): Optimized for scanning US-region resources
- **EU Scanner** (`europe-west1`): Optimized for scanning EU-region resources
- Both scanners can scan any project where they have impersonation permissions
- Reduces cross-region egress charges by scanning locally

### API Key Configuration

By default, this example passes the Datadog API key directly via `api_key`. The module stores it in Google Secret Manager automatically.

To reference a **pre-existing** Secret Manager secret instead, modify both module blocks in `scanner_project/main.tf`:

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

## Security Considerations

- Each project controls which scanner service accounts can impersonate its resources
- Separate service accounts per region provide isolation
- All impersonation events are logged in Cloud Audit Logs
- Impersonated service accounts have read-only permissions

## Cleanup

To remove all resources, destroy scanned projects first, then the scanner project. This order ensures the impersonated service accounts are removed before the scanner infrastructure they depend on.

```sh
# 1. In each other_project deployment
cd other_project_<name>
terraform destroy \
  -var="scanned_project_id=<my-other-project>" \
  -var="scanner_service_account_email_us=$SCANNER_SA_US" \
  -var="scanner_service_account_email_eu=$SCANNER_SA_EU" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=datadoghq.com"

# 2. In the scanner project (after all other_project deployments are destroyed)
cd ../scanner_project
terraform destroy \
  -var="scanner_project_id=<my-scanner-project>" \
  -var="datadog_api_key=$DD_API_KEY" \
  -var="datadog_app_key=$DD_APP_KEY" \
  -var="datadog_site=datadoghq.com"
```

> **Note**: To remove a single scanned project while keeping others, only run `terraform destroy` in that project's directory (e.g., `other_project_teamA`). Each directory has independent Terraform state, so destroying one does not affect others.

## Troubleshooting

See the [Troubleshooting section](../README.md#troubleshooting) for common issues and debugging commands.
