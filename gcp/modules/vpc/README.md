# GCP VPC Module

This module creates a VPC network infrastructure for the Datadog Agentless Scanner in Google Cloud Platform.

## Features

- **VPC Network**: Creates a custom VPC network with configurable subnets
- **NAT Gateway**: Optional Cloud NAT for outbound internet access from private instances
- **Firewall Rules**: Configurable firewall rules for SSH, HTTP/HTTPS, and internal communication
- **Private Google Access**: Enables instances to reach Google APIs without external IPs
- **Private Service Connect**: Optional endpoint for private Google APIs access

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name       = "datadog-scanner"
  region     = "us-central1"
  subnet_cidr = "10.0.1.0/24"
  
  enable_ssh  = true
  
  ssh_source_ranges = ["0.0.0.0/0"]
  
  tags = {
    Environment = "production"
    Purpose     = "agentless-scanning"
  }
}
```

## Resources Created

- `google_compute_network` - VPC network
- `google_compute_subnetwork` - Subnet for instances
- `google_compute_router` - Cloud Router (if NAT enabled)
- `google_compute_router_nat` - NAT Gateway (if NAT enabled)
- `google_compute_firewall` - Firewall rules for traffic control
- `google_compute_global_address` - Private Service Connect address (if enabled)
- `google_compute_global_forwarding_rule` - Private Service Connect endpoint (if enabled)

## Inputs

| Name                           | Description                                                | Type           | Default                       | Required |
| ------------------------------ | ---------------------------------------------------------- | -------------- | ----------------------------- | :------: |
| name                           | Name prefix for VPC resources                              | `string`       | `"datadog-agentless-scanner"` |    no    |
| region                         | The region to deploy VPC resources                         | `string`       | n/a                           |   yes    |
| subnet_cidr                    | The CIDR block for the subnet                              | `string`       | `"10.0.0.0/24"`               |    no    |
| secondary_ranges               | Secondary IP ranges for the subnet                         | `list(object)` | `[]`                          |    no    |
| enable_nat                     | Whether to enable NAT Gateway for outbound internet access | `bool`         | `true`                        |    no    |
| enable_ssh                     | Whether to enable SSH firewall rule                        | `bool`         | `true`                        |    no    |
| ssh_source_ranges              | Source IP ranges allowed for SSH access                    | `list(string)` | `["0.0.0.0/0"]`               |    no    |
| enable_http                    | Whether to enable HTTP/HTTPS firewall rules                | `bool`         | `false`                       |    no    |
| enable_private_service_connect | Whether to enable Private Service Connect for Google APIs  | `bool`         | `false`                       |    no    |
| tags                           | A map of additional labels to add to resources             | `map(string)`  | `{}`                          |    no    |

## Outputs

| Name                            | Description                                              |
| ------------------------------- | -------------------------------------------------------- |
| vpc                             | The VPC network created                                  |
| vpc_id                          | The ID of the VPC network                                |
| vpc_name                        | The name of the VPC network                              |
| subnet                          | The subnet created                                       |
| subnet_id                       | The ID of the subnet                                     |
| subnet_name                     | The name of the subnet                                   |
| network_name                    | The name of the VPC network (for backward compatibility) |
| subnetwork_name                 | The name of the subnet (for backward compatibility)      |
| router                          | The Cloud Router (if NAT is enabled)                     |
| nat_gateway                     | The NAT Gateway (if enabled)                             |
| private_service_connect_address | The Private Service Connect address (if enabled)         |

## Security Considerations

- The default configuration allows SSH access from anywhere (`0.0.0.0/0`). Consider restricting this to specific IP ranges.
- Internal communication is allowed within the VPC subnet by default.
- NAT Gateway is enabled by default to provide secure outbound internet access.
- HTTP/HTTPS access is disabled by default for security.

## Network Architecture

```
Internet
    |
[NAT Gateway] ← [Cloud Router]
    |
[VPC Network]
    |
[Subnet] ← [Instances]
```

The instances can access the internet through the NAT Gateway while remaining in a private subnet, providing enhanced security. 