# GCP Examples for Datadog Agentless Scanner

This directory contains example Terraform configurations for deploying the Datadog Agentless Scanner on Google Cloud Platform (GCP).

## Available Examples

### [Single Region](./single_region/) - **Simple Setup**

Deploy Agentless scanners in a single GCP region within a single project. Instances are distributed across multiple zones for high availability. This is the **recommended starting point** for most users.

**Use this when:**
- Your resources are in one project and primarily in one region
- You want the simplest deployment model

**What it deploys:**
- A scanner compute instance as part of a Managed Instance Group
- Single region (configured via the Google provider)
- VPC network with multi-zone distribution
- Service accounts for scanning within the same project

---

### [Cross Project](./cross_project/) - **Advanced Setup**

Deploy Agentless scanners across **multiple regions** in one GCP project, while scanning resources in **other GCP projects**. This is the **recommended deployment model** for production environments with distributed infrastructure.

**Use this when:**
- You have multiple GCP projects to scan
- Your resources are distributed across multiple regions
- You want to minimize cross-region data transfer costs
- You need centralized scanner management

**What it deploys:**
- Each region has its own VPC and scanner instances
- Cross-project service account impersonation setup
- Ability to scan multiple other projects

---

## Quick Comparison

| Feature | Single Region | Cross Project |
|---------|--------------|---------------|
| **Complexity** | Simple | Advanced |
| **Projects Scanned** | Single project | Multiple projects |
| **Regions Covered** | Single region | Multiple regions |
| **Cross-Region Costs** | Higher (if resources are multi-region) | Lower (regional scanners) |
| **Use Case** | Single project | multi-project orgs |
| **Management** | Simple | Centralized |
| **Redundancy** | Zone-level | Region-level |

## Decision Tree

```
Start here ──┐
             │
             ▼
   ┌─────────────────────────┐
   │ Do you have multiple    │
   │ GCP projects to scan?   │
   └─────────┬───────────────┘
             │
      ┌──────┴──────┐
      │             │
     NO            YES
      │             │
      ▼             ▼
   [single_region]  [cross_project]
   Simple Setup     Advanced Setup
```

**Recommendation:** Start with `single_region` to understand the basics, then migrate to `cross_project` if you need to scan multiple projects or want multi-region deployment.

## Getting Started

### Prerequisites

Before using any example, ensure you have:

1. **Terraform** v1.0 or later installed
2. **Google Cloud CLI** (`gcloud`) installed and configured
3. **GCP Credentials** configured:
   ```bash
   gcloud auth application-default login
   ```
4. **GCP Project** with the following APIs enabled:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable iamcredentials.googleapis.com
   gcloud services enable secretmanager.googleapis.com
   ```
5. **Datadog API Key** with Remote Configuration enabled ([Get your API key](https://docs.datadoghq.com/account_management/api-app-keys/))
6. **GCP Permissions** to create:
   - VPC networks and subnets
   - Compute Engine instances and templates
   - Service accounts and IAM bindings
   - Secret Manager secrets

### Basic Deployment Steps

1. **Choose your example** (start with `single_region` if unsure)

2. **Configure your GCP project:**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Authenticate with GCP:**
   ```bash
   gcloud auth application-default login
   ```

4. **Navigate to the example directory:**
   ```bash
   cd single_region  # or cross_project
   ```

5. **Initialize Terraform:**
   ```bash
   terraform init
   ```

6. **Review the planned changes:**
   ```bash
   terraform plan \
     -var="project_id=YOUR_PROJECT_ID" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

7. **Apply the configuration:**
   ```bash
   terraform apply \
     -var="project_id=YOUR_PROJECT_ID" \
     -var="datadog_api_key=$DD_API_KEY" \
     -var="datadog_site=datadoghq.com"
   ```

6. **Verify in Datadog** that your scanner is reporting

## Architecture Overview

### Single Region Architecture

```
┌─────────────────────────────────────────┐
│ GCP Project                             │
│                                         │
│  ┌────────────────────────────────┐    │
│  │ VPC Network (us-central1)      │    │
│  │  - Private Subnet              │    │
│  │  - Cloud Router & NAT          │    │
│  └────────────────────────────────┘    │
│                                         │
│  ┌────────────────────────────────┐    │
│  │ MIG (Multi-zone)               │    │
│  │  - Zone A: Scanner Instance    │    │
│  │  - Zone B: Scanner Instance    │    │
│  │  - Zone C: Scanner Instance    │    │
│  └────────────────────────────────┘    │
│                                         │
│  ┌────────────────────────────────┐    │
│  │ Service Accounts               │    │
│  │  - Scanner SA                  │    │
│  │  - Impersonated SA             │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### Cross Project Architecture

```
┌─────────────────────────────────────────┐
│   Scanner Project                       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ US Region (us-central1)         │   │
│  │  - VPC & Scanner Instances      │   │
│  │  - Scanner SA US                │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ EU Region (europe-west1)        │   │
│  │  - VPC & Scanner Instances      │   │
│  │  - Scanner SA EU                │   │
│  └─────────────────────────────────┘   │
└────────────┬────────────┬───────────────┘
             │            │
             │ impersonate│
             │            │
┌────────────▼────────────▼───────────────┐
│   Other Projects (repeatable)           │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ Impersonated SA (US)             │  │
│  │ Impersonated SA (EU)             │  │
│  └───────────┬──────────────────────┘  │
│              │ scan                     │
│  ┌───────────▼──────────────────────┐  │
│  │ Compute Resources                │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Cost Considerations

### Single Region
- **Network Costs**: Minimal for local resources, higher for cross-region scanning
- **Compute Costs**: 1 instance by default
- **Best For**: Small to medium workloads in one region

### Cross Project
- **Network Costs**: Minimized by scanning locally per region
- **Compute Costs**: Multiple instances (1 per region by default)
- **Best For**: Large, distributed workloads across multiple projects/regions

### Cost Optimization Tips
1. Start with single region to understand scanning patterns
2. Use committed use discounts for long-term deployments
3. Adjust instance counts based on actual scanning needs
4. Monitor usage in Datadog to identify optimization opportunities
5. Use regional scanners to avoid cross-region egress charges

## Security Best Practices

1. **Principle of Least Privilege**: Service accounts have minimal required permissions
2. **Private Instances**: No external IP addresses on scanner instances
3. **VPC Isolation**: Dedicated VPC for scanner infrastructure
4. **API Key Security**: Stored in Google Secret Manager, never in code
5. **Audit Logging**: Enable Cloud Audit Logs for compliance tracking
6. **Firewall Rules**: Restrict access to only required ports and health checks
7. **Service Account Impersonation**: Provides auditable, revocable access control

## Troubleshooting

### Common Issues

**Issue**: Instances not starting
- **Check**: Required APIs are enabled (`gcloud services list --enabled`)
- **Check**: You have proper IAM permissions
- **Solution**: Enable missing APIs and verify permissions

**Issue**: Scanner not connecting to Datadog
- **Check**: Private Google Access is enabled on subnet
- **Check**: Cloud NAT is configured and working
- **Solution**: Verify network configuration in GCP Console

**Issue**: Permission errors during deployment
- **Required Roles**:
  - `roles/compute.admin` or equivalent
  - `roles/iam.serviceAccountAdmin`
  - `roles/secretmanager.admin`
- **Solution**: Request necessary permissions from project admin

**Issue**: Cross-project scanning failing (cross_project example)
- **Check**: Impersonated service accounts exist in target project for both regions
- **Check**: Scanner service accounts have impersonation permissions
- **Solution**: Verify IAM bindings in other_project deployment

### Debugging Commands

```bash
# List instances
gcloud compute instances list --filter="name:datadog-agentless"

# Check MIG status
gcloud compute instance-groups managed describe <MIG_NAME> --region=<REGION>

# View instance logs
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=<INSTANCE_ID>" --limit 50

# SSH to instance (if configured with SSH)
gcloud compute ssh <INSTANCE_NAME> --tunnel-through-iap

# Check scanner status on instance
sudo systemctl status datadog-agentless-scanner
```

## Next Steps

After successful deployment:

1. ✅ Verify scanners appear in Datadog Infrastructure
2. ✅ Check that resources are being discovered
3. ✅ Review initial vulnerability findings
4. ✅ Set up alerting for scanner health
5. ✅ Document your deployment for your team
6. ✅ Consider scaling to cross_project if needed

## Additional Resources

- [GCP Module Documentation](../README.md)
- [Datadog Agentless Scanning Documentation](https://docs.datadoghq.com/security/cloud_security_management/agentless_scanning/)
- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Service Account Impersonation](https://cloud.google.com/iam/docs/impersonating-service-accounts)
- [GCP Compute Engine Best Practices](https://cloud.google.com/compute/docs/best-practices)

## Support

For issues or questions:
- 📖 [Datadog Documentation](https://docs.datadoghq.com/)
- 💬 [Datadog Support](https://www.datadoghq.com/support/)
- 🐛 [GitHub Issues](https://github.com/DataDog/terraform-module-datadog-agentless-scanner/issues)
- 📧 Contact your Datadog account team
