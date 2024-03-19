# Single Region Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner) to deploy a Datadog agentless scanner in your [AWS](https://aws.amazon.com/) account.

To deploy in multiple regions you can check this [example](../multi_region/README.md).
If you are interested to scan your other accounts you can check that [example](../cross_account/README.md)

## Quick start

To deploy a Datadog agentless scanner:

1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).
