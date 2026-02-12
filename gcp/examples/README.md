# GCP Examples for Datadog Agentless Scanner

This directory contains example Terraform configurations for deploying the Datadog Agentless Scanner on Google Cloud Platform (GCP).

## Deployment Playbooks

Pick the playbook that matches your setup. Datadog recommends **multi-project, multi-region** for production environments.

| | **Single Region** | **Multiple Regions** |
|---|---|---|
| **Single Project** | [single_project_single_region](./single_project_single_region/) | [single_project_multi_region](./single_project_multi_region/) |
| **Multiple Projects** | [multi_project_single_region](./multi_project_single_region/) | [multi_project_multi_region](./multi_project_multi_region/) (recommended) |

---

### [single_project_single_region](./single_project_single_region/) - Getting Started

Deploy a scanner in a single GCP region within a single project. Instances are distributed across multiple zones for high availability. **Best for evaluation or single-project setups.**

**Use this when:**
- Your resources are in one project and primarily in one region
- You want the simplest deployment model

**What it deploys:**
- A scanner compute instance as part of a Managed Instance Group
- VPC network with multi-zone distribution
- Service accounts for scanning within the same project

---

### [single_project_multi_region](./single_project_multi_region/) - Single Project, Multiple Regions

Deploy scanners in **multiple regions** within a single GCP project to minimize cross-region data transfer costs.

**Use this when:**
- Your resources are in one project but spread across multiple regions
- You want to reduce cross-region egress charges

**What it deploys:**
- A scanner instance per region (US and EU by default)
- Separate VPC network per region
- Shared service accounts within the project

---

### [multi_project_single_region](./multi_project_single_region/) - Multiple Projects, Single Region

Deploy a scanner in a dedicated project and scan resources across **other GCP projects**, all within a single region.

**Use this when:**
- You have multiple GCP projects to scan
- Your resources are primarily in one region
- You want centralized scanner management

**What it deploys:**
- Scanner infrastructure in a dedicated project (single region)
- Cross-project service account impersonation setup
- Repeatable configuration for each scanned project

---

### [multi_project_multi_region](./multi_project_multi_region/) - Production (Recommended)

Deploy scanners across **multiple regions** in a dedicated project, while scanning resources in **other GCP projects**. This is the **recommended deployment model** for production environments.

**Use this when:**
- You have multiple GCP projects to scan
- Your resources are distributed across multiple regions
- You want to minimize cross-region data transfer costs
- You need centralized scanner management

**What it deploys:**
- Regional scanner infrastructure (US and EU by default) in a dedicated project
- Cross-project service account impersonation setup
- Repeatable configuration for each scanned project

---

## Quick Comparison

| Feature | single_project_single_region | single_project_multi_region | multi_project_single_region | multi_project_multi_region |
|---------|-----|-----|-----|-----|
| **Complexity** | Simple | Moderate | Moderate | Advanced |
| **Projects scanned** | 1 | 1 | Many | Many |
| **Regions covered** | 1 | Many | 1 | Many |
| **Cross-region costs** | Higher (if multi-region) | Lower | N/A | Lower |
| **Cross-project scanning** | No | No | Yes | Yes |
| **Best for** | Evaluation | Single project, multi-region | Multi-project, single region | Production |

## Decision Tree

```
Start here
    |
    v
Do you have multiple GCP projects to scan?
    |                   |
   NO                  YES
    |                   |
    v                   v
Single project      Multiple projects
    |                   |
    v                   v
Are resources in      Are resources in
multiple regions?     multiple regions?
  |         |           |         |
 NO        YES         NO        YES
  |         |           |         |
  v         v           v         v
single_   single_     multi_    multi_
project_  project_    project_  project_
single_   multi_      single_   multi_
region    region      region    region
```

**Recommendation:** Start with `single_project_single_region` to understand the basics, then migrate to a multi-project playbook when ready for production.

## Prerequisites

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
5. **Datadog API Key**, **APP Key**, and **Site** — in the [Cloud Security Setup page](https://app.datadoghq.com/security/configuration/csm/setup?active_steps=cloud-accounts&active_sub_step=gcp), select your GCP project, click **Enable**, choose **Terraform**, then copy from steps 2-4
6. **GCP Permissions** to create:
   - VPC networks and subnets
   - Compute Engine instances and templates
   - Service accounts and IAM bindings
   - Secret Manager secrets

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

**Issue**: Instances running in GCP but no scan results in Datadog
- **Note**: First scan results can take 15-30 minutes after instances become healthy. Do not troubleshoot prematurely.
- **Check**: Cloud NAT is provisioned and has an active NAT IP (`gcloud compute routers nats list --router=<ROUTER_NAME> --region=<REGION>`)
- **Check**: The Datadog API key stored in Secret Manager is valid and has Remote Configuration enabled
- **Check**: The instance startup script completed (`gcloud compute instances get-serial-port-output <INSTANCE_NAME> --zone=<ZONE>`)
- **Solution**: If results have not appeared after 30 minutes, SSH into the instance via IAP and check `sudo systemctl status datadog-agentless-scanner` and `sudo journalctl -u datadog-agentless-scanner --no-pager -n 100`

**Issue**: Permission errors during deployment
- **Required Roles**:
  - `roles/compute.admin` or equivalent
  - `roles/iam.serviceAccountAdmin`
  - `roles/secretmanager.admin`
- **Solution**: Request necessary permissions from project admin

**Issue**: Cross-project scanning failing
- **Check**: Impersonated service accounts exist in target project
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

## Additional Resources

- [GCP Module Documentation](../README.md)
- [Datadog Agentless Scanning Documentation](https://docs.datadoghq.com/security/cloud_security_management/agentless_scanning/)
- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Service Account Impersonation](https://cloud.google.com/iam/docs/impersonating-service-accounts)
