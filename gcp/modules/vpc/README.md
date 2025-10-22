# VPC Module

This module creates a secure Virtual Private Cloud (VPC) network infrastructure for the Datadog Agentless Scanner on Google Cloud Platform. It provides isolated networking with private instances that have outbound internet access through a NAT gateway.

## Overview

The module creates:
- VPC network with custom subnets (no default auto-created subnets)
- Private subnet with Google Cloud API access enabled
- Cloud Router and NAT Gateway for outbound internet connectivity
- Firewall rules for health checks and optional SSH access via Identity-Aware Proxy
- Proper security controls with minimal required access

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name          = "datadog-agentless-scanner"
  subnet_cidr   = "10.0.0.0/24"
  unique_suffix = "abc123"
  enable_ssh    = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0, < 7.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0, < 7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [random_id.deployment_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Whether to enable SSH firewall rule | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for VPC resources | `string` | `"datadog-agentless-scanner"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | The CIDR block for the subnet | `string` | `"10.0.0.0/24"` | no |
| <a name="input_unique_suffix"></a> [unique\_suffix](#input\_unique\_suffix) | Unique suffix to append to resource names to avoid collisions. Must be alphanumeric only (no hyphens or underscores) and maximum 8 characters. If not provided, a random suffix is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | The name of the VPC network (for backward compatibility) |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | The subnet created for the Datadog agentless scanner |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the subnet |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | The name of the subnet |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The VPC network created for the Datadog agentless scanner |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC network |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC network |
<!-- END_TF_DOCS -->