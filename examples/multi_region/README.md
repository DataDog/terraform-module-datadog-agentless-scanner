# Multi Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner) to deploy a Datadog Agentless scanner in multiple regions in your [AWS](https://aws.amazon.com/) account.

In this example the full scanner setup is deployed in the `us-east-1` and `eu-central-1`.
You will need to leverage the [multiple provider configurations](https://developer.hashicorp.com/terraform/language/providers/configuration#alias-multiple-provider-configurations) feature of Terraform.

The `scanning-delegate-role` and `agentless-scanner-role` modules which are creating IAM resource are only created once as IAM is a global service, you can thus use any regional provider to create them.

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).
