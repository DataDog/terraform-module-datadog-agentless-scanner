# SaaS Example

This folder shows an example of Terraform code that uses the [agentless-scanning-saas module](../../modules/agentless-scanning-saas/) to enable Datadog Agentless Scanning in SaaS mode in your [AWS](https://aws.amazon.com/) account.

In SaaS mode, Datadog performs the scans from its own infrastructure by assuming the Datadog integration role: no scanner is deployed in your account. The module only attaches the scanning permissions to the Datadog integration role.

## Quick start

1. Make sure your AWS account is integrated with Datadog, and note the name of the Datadog integration IAM role.
1. Run `terraform init`.
1. Run `terraform apply`, and provide your Datadog [API and application keys](https://docs.datadoghq.com/account_management/api-app-keys/), your [Datadog site](https://docs.datadoghq.com/getting_started/site/) and the Datadog integration role name.
