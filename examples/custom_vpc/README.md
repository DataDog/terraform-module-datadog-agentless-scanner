# Custom VPC Example

This folder shows an example of Terraform code let you deploy the Datadog agentless scanner in your own managed VPC.

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).
1. Set the `subnet_ids` list with the subnet IDs you want the agentless scanner to be deployed in.

## Warning

When deploying in a managed VPC, you need to make sure the instance has proper access to the open internet and VPC endpoints to avoid additional network costs.
You can look at the `vpc` module to see what default VPC endpoints are created in more details.
