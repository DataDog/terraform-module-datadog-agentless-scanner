# Instance Module

This module creates a Google Cloud Managed Instance Group (MIG) with Datadog Agentless Scanner instances. The MIG provides auto-scaling, auto-healing, and high availability across multiple zones.

## Overview

The module creates:
- Instance template and startup script for scanner installation
- Regional Managed Instance Group for high availability and auto-healing
- Secret Manager secret for storing the Datadog API key (if not provided)
- Proper distribution across multiple zones for fault tolerance

## Usage

```hcl
module "instance" {
  source = "./modules/instance"

  zones                 = ["us-central1-a", "us-central1-b", "us-central1-c"]
  network_name          = "datadog-agentless-scanner-vpc"
  subnetwork_name       = "datadog-agentless-scanner-subnet"
  service_account_email = "scanner-sa@project.iam.gserviceaccount.com"
  
  api_key            = var.datadog_api_key
  site               = "datadoghq.com"
  ssh_public_key     = var.ssh_public_key
  ssh_username       = "ubuntu"
  instance_count     = 3
  scanner_version    = "0.11"
  scanner_channel    = "stable"
  scanner_repository = "https://apt.datadoghq.com/"
  unique_suffix      = "abc123"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_health_check.agentless_scanner_health](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.agentless_scanner_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_instance_group_manager.agentless_scanner_mig](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_secret_manager_secret.api_key_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.api_key_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [null_resource.api_key_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.deployment_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Datadog API key. Either api\_key or api\_key\_secret\_id must be provided, but not both. | `string` | `null` | no |
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | Identifier of the pre-provisioned Secret Manager secret containing the Datadog API key | `string` | `null` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances in the managed instance group | `number` | `1` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network | `string` | n/a | yes |
| <a name="input_scanner_channel"></a> [scanner\_channel](#input\_scanner\_channel) | Specifies the channel to use for installing the scanner | `string` | n/a | yes |
| <a name="input_scanner_repository"></a> [scanner\_repository](#input\_scanner\_repository) | Repository URL to install the scanner from. | `string` | n/a | yes |
| <a name="input_scanner_version"></a> [scanner\_version](#input\_scanner\_version) | Specifies the version of the scanner to install | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email of the service account to attach to instances | `string` | n/a | yes |
| <a name="input_site"></a> [site](#input\_site) | Datadog site (for example, datadoghq.com, datadoghq.eu) | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for instance access | `string` | `null` | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Username for SSH access | `string` | n/a | yes |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | The name of the subnetwork | `string` | n/a | yes |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to append to resource names to avoid collisions. Must be alphanumeric only (no hyphens or underscores) and maximum 8 characters. If not provided, a random suffix is generated. | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | List of zones to deploy resources across | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key_secret_id"></a> [api\_key\_secret\_id](#output\_api\_key\_secret\_id) | The name of the Secret Manager secret containing the Datadog API key |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | The health check for auto-healing |
| <a name="output_instance_group_manager"></a> [instance\_group\_manager](#output\_instance\_group\_manager) | The managed instance group manager |
| <a name="output_instance_template"></a> [instance\_template](#output\_instance\_template) | The instance template used by the MIG |
| <a name="output_mig_target_size"></a> [mig\_target\_size](#output\_mig\_target\_size) | Target size of the managed instance group |
| <a name="output_zones"></a> [zones](#output\_zones) | Zones where instances are distributed |
<!-- END_TF_DOCS -->