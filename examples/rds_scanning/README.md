# RDS Scanning Example

This folder shows an example of Terraform code to deploy the necessary resources to perform Agentless scanning on RDS databases.
This example enables RDS scanning in two different AWS regions: `us-east-1` and `eu-central-1`.

The TF code in this example uses the [agentless-s3-bucket module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner/modules/agentless-s3-bucket)
to deploy the necessary artifacts to perform RDS scanning in the two specified regions, as well as the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner) 
to deploy a Datadog Agentless scanner in multiple regions in your [AWS](https://aws.amazon.com/) account.

The `scanning-delegate-role` and `agentless-scanner-role` modules, which create IAM resources, are only created once, as IAM is a global service. You can thus use any regional provider to create the modules.

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).
