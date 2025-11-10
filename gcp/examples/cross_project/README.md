# Cross-Project Example (Advanced)

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/tree/main/gcp) to deploy Datadog Agentless scanners across **multiple regions** in one GCP project, while scanning resources in **other GCP projects**.

This is the **advanced deployment model** that combines:
- Multi-region deployment for cost optimization (US and EU)
- Cross-project scanning for centralized management

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

Use this **advanced** deployment model when:
- You have multiple GCP projects to scan
- Your resources are distributed across multiple regions
- You want to minimize cross-region data transfer costs
- You need centralized scanner management

## Quick start

### Step 1: Deploy the Multi-Region Scanner Infrastructure

1. **Configure your GCP project**:
   ```sh
   gcloud config set project my-scanner-project
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

1. **Review the deployment plan**. You will need to:
   - Set the project ID where the scanner will be deployed
   - Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/)
   - Set your Datadog site

   ```sh
   terraform plan \
     -var="scanner_project_id=my-scanner-project" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

1. **Deploy the scanner infrastructure**:
   ```sh
   terraform apply \
     -var="scanner_project_id=my-scanner-project" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

1. **Save the outputs for the next step**:
   ```sh
   SCANNER_SA_US=$(terraform output -raw scanner_service_account_email_us)
   SCANNER_SA_EU=$(terraform output -raw scanner_service_account_email_eu)
   ```

### Step 2: Set up Other Projects for Scanning

1. Go to the `other_project` folder.
1. Configure your other gcp project `gcloud config set project my-other-project`.
1. Run `terraform init`.
1. Run `terraform plan` to review the changes.
1. Run `terraform apply` to deploy.
1. Set the project ID to be scanned.
1. Set both scanner service account emails from Step 1.

Example:
```sh
cd ../other_project
gcloud config set project my-other-project
terraform init
terraform plan \
  -var="scanned_project_id=my-other-project" \
  -var="scanner_service_account_email_us=$SCANNER_SA_US" \
  -var="scanner_service_account_email_eu=$SCANNER_SA_EU"
terraform apply \
  -var="scanned_project_id=my-other-project" \
  -var="scanner_service_account_email_us=$SCANNER_SA_US" \
  -var="scanner_service_account_email_eu=$SCANNER_SA_EU"
```

Repeat Step 2 for each additional project you want to scan.

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

## Prerequisites

- Multiple GCP projects with appropriate permissions
- APIs enabled in all projects:
  - Compute Engine API
  - IAM Service Account Credentials API
  - Secret Manager API (scanner project only)
- Datadog API key with Remote Configuration enabled
- Permissions to create service accounts and IAM bindings across projects

### API Key Configuration

You have two options for providing the Datadog API key:

1. **Pass the API key directly** (shown in examples above):
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

## Security Considerations

- Each project controls which scanner service accounts can impersonate its resources
- Separate service accounts per region provide isolation
- All impersonation events are logged in Cloud Audit Logs
- Impersonated service accounts have read-only permissions

## Cleanup

To remove all resources:

```sh
# In each other_project deployment
cd other_project
terraform destroy

# In the scanner project (removes both regions)
cd ../scanner_project
terraform destroy
```
