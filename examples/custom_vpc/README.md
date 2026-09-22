# Custom VPC Example

This folder shows an example of Terraform code let you deploy the Datadog agentless scanner in your own managed VPC.

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/) (`api_key`).
1. Set `datadog_site` to your Datadog site (e.g. `datadoghq.eu`) if your organization is not on the default US site.
1. Set the `vpc_id` and the `subnet_ids` list with the VPC and subnet IDs you want the agentless scanner to be deployed in.
1. Set `datadog_integration_role` to the AWS role name used by your Datadog AWS integration (required by the autoscaling module).

## Warning

When deploying in a managed VPC, you need to make sure the instance has proper access to the open internet and VPC endpoints to avoid additional network costs.
You can look at the `vpc` module to see what default VPC endpoints are created in more details.

### Subnet egress requirement

The scanner instance is **not** assigned a public IP. It must reach the internet (to install the scanner and report to Datadog) through outbound egress on the subnet you pass in `subnet_ids`. The most common deployment failure is picking a subnet without a working egress path.

Pick subnets that satisfy **one** of the following:

- **(Recommended) Private subnet behind a NAT gateway** — the subnet's route table has `0.0.0.0/0 -> nat-...`, and the NAT gateway itself lives in a public subnet routed to an internet gateway. This matches the default `vpc` module behavior.
- **Public subnet with auto-assigned public IP** — the subnet's route table has `0.0.0.0/0 -> igw-...` **and** `map_public_ip_on_launch = true`.

> [!IMPORTANT]
> A public subnet (route to an internet gateway) with `map_public_ip_on_launch = false` will **not** work: the instance gets no public IP and an internet gateway cannot route traffic for a private-only host, so all outbound connections time out. If you rely on a NAT gateway, double-check the route table actually associated with your subnet points to it.

To reduce cross-region/data-transfer costs when scanning, ensure the VPC also has S3 (gateway) and EBS (interface) endpoints, as created by the `vpc` module.
