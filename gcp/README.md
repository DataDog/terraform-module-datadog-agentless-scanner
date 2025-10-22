# Terraform Module Datadog Agentless Scanner Module

This Terraform module provides a simple and reusable configuration for installing a Datadog Agentless Scanner on Google Cloud Platform (GCP).

## Prerequisites

Before using this module, make sure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your local machine.
2. The [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed on your local machine.
3. GCP credentials configured (`gcloud auth login`) with the necessary permissions.

## Usage

To use this module in your Terraform configuration, add the following code in your existing Terraform code:

```hcl
variable "datadog-api-key" {}

module "datadog-agentless-scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//gcp"

  site           = "datadoghq.com"
  vpc_name       = "datadog-agentless-scanner"
  api_key        = var.datadog-api-key
}
```

And run:
```sh
terraform init
export GOOGLE_PROJECT="your-project-id"
export GOOGLE_REGION="us-central1"
terraform apply -var="datadog-api-key=$DD_API_KEY"
```

### Notes

- `site` must match the Datadog site parameter of your account (see [this table](https://docs.datadoghq.com/getting_started/site/#access-the-datadog-site)).
- `vpc_name` is the name prefix for the VPC resources where the Agentless scanner
  is created. For security reasons, this VPC should be reserved for
  the exclusive use of the scanner.
- The scanner requires a service account with appropriate permissions to scan disks
  in your GCP project. This module creates the necessary service accounts and IAM roles.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agentless_impersonated_service_account"></a> [agentless\_impersonated\_service\_account](#module\_agentless\_impersonated\_service\_account) | ./modules/agentless-impersonated-service-account | n/a |
| <a name="module_agentless_scanner_service_account"></a> [agentless\_scanner\_service\_account](#module\_agentless\_scanner\_service\_account) | ./modules/agentless-scanner-service-account | n/a |
| <a name="module_instance"></a> [instance](#module\_instance) | ./modules/instance | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.api_key_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ssh_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.deployment_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Datadog API key. Required when not using api\_key\_secret\_id. | `string` | `null` | no |
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | Identifier of the pre-provisioned Secret Manager secret containing the Datadog API key. Alternative to api\_key. | `string` | `null` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Whether to enable SSH firewall rule | `bool` | `false` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances in the managed instance group | `number` | `1` | no |
| <a name="input_scanner_channel"></a> [scanner\_channel](#input\_scanner\_channel) | Specifies the channel to use for installing the scanner | `string` | `"stable"` | no |
| <a name="input_scanner_repository"></a> [scanner\_repository](#input\_scanner\_repository) | Repository URL to install the scanner from. | `string` | `"https://apt.datadoghq.com/"` | no |
| <a name="input_scanner_version"></a> [scanner\_version](#input\_scanner\_version) | Specifies the version of the scanner to install | `string` | `"0.11"` | no |
| <a name="input_site"></a> [site](#input\_site) | Datadog site (for example, datadoghq.com, datadoghq.eu) | `string` | `"datadoghq.com"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for instance access | `string` | `null` | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Username for SSH access | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The CIDR block for the subnet | `string` | `"10.0.0.0/24"` | no |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to append to resource names to avoid collisions. Must be alphanumeric only (no hyphens or underscores) and maximum 8 characters. If not provided, a random suffix is generated. | `string` | `""` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name prefix for VPC resources | `string` | `"datadog-agentless-scanner"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | List of zones to deploy resources across. If empty, up to 3 zones in the region are automatically selected. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | The health check for auto-healing |
| <a name="output_instance_group_manager"></a> [instance\_group\_manager](#output\_instance\_group\_manager) | The managed instance group manager |
| <a name="output_instance_template"></a> [instance\_template](#output\_instance\_template) | The instance template used by the MIG |
| <a name="output_mig_target_size"></a> [mig\_target\_size](#output\_mig\_target\_size) | Target size of the managed instance group |
| <a name="output_scanner_service_account_email"></a> [scanner\_service\_account\_email](#output\_scanner\_service\_account\_email) | Email of the scanner service account |
| <a name="output_target_service_account_email"></a> [target\_service\_account\_email](#output\_target\_service\_account\_email) | Email of the target service account |
| <a name="output_unique_suffix"></a> [unique\_suffix](#output\_unique\_suffix) | Unique suffix used in resource names |
| <a name="output_vpc_network"></a> [vpc\_network](#output\_vpc\_network) | The VPC network created for the scanner |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | The name of the VPC network |
| <a name="output_vpc_subnet"></a> [vpc\_subnet](#output\_vpc\_subnet) | The subnet created for the scanner |
| <a name="output_vpc_subnet_name"></a> [vpc\_subnet\_name](#output\_vpc\_subnet\_name) | The name of the VPC subnet |
| <a name="output_zones"></a> [zones](#output\_zones) | Zones where instances are deployed |
<!-- END_TF_DOCS -->