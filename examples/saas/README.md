# Datadog-hosted (SaaS) Example

This folder shows how to enable Datadog Agentless Scanning in **Datadog-hosted (SaaS) mode** in your [AWS](https://aws.amazon.com/) account, using the [agentless-scanning-policy module](../../modules/agentless-scanning-policy/).

In Datadog-hosted mode, Datadog performs the scans from its own infrastructure by assuming your Datadog integration role. No scanner, VPC or EC2 instance is deployed in your account.

## What this creates

In your AWS account:

- `aws_iam_policy`: a managed policy named `DatadogAgentlessScanningPolicy*`, holding all the scanning permissions (snapshots, EBS direct APIs, Lambda, ECR, and S3 for sensitive data scanning)
- `aws_iam_role_policy_attachment`: attaches that policy to your existing Datadog integration role

In Datadog:

- `datadog_agentless_scanning_aws_scan_options`: turns on scanning for this AWS account and sets which scan types run

The policy must be a managed policy, not inline: the document is close to the inline policy size limit, and Datadog needs its ARN.

## Prerequisites

- Your AWS account is [integrated with Datadog](https://docs.datadoghq.com/integrations/amazon_web_services/).
- The name of that integration's IAM role. Find it on the AWS integration tile in Datadog, or in IAM. If you set up the integration with Datadog's CloudFormation template, it's usually `DatadogIntegrationRole`.
- A Datadog [API key and application key](https://docs.datadoghq.com/account_management/api-app-keys/).
- Your [Datadog site](https://docs.datadoghq.com/getting_started/site/) (for example `datadoghq.com` or `datadoghq.eu`).
- AWS credentials for the account you want to scan, with permission to create IAM policies and attach them to roles.

Unlike self-hosted mode, you don't need Remote Configuration enabled on the API key.

## Quick start

1. Run `terraform init`.
1. Run `terraform apply`. You'll be prompted for:

   | Variable | Value |
   |---|---|
   | `datadog_api_key` | Your Datadog API key |
   | `datadog_app_key` | Your Datadog application key |
   | `datadog_site` | Your Datadog site, for example `datadoghq.com` |
   | `datadog_integration_role` | The integration role **name** (not the ARN), for example `DatadogIntegrationRole` |

   Or put them in a `terraform.tfvars` file:

   ```hcl
   datadog_api_key          = "<API_KEY>"
   datadog_app_key          = "<APP_KEY>"
   datadog_site             = "datadoghq.com"
   datadog_integration_role = "DatadogIntegrationRole"
   ```

1. Check the result: in Datadog, go to the Agentless Scanning setup page and confirm the account shows as enabled.

   <!-- TODO(PM): add expected time to first results and the exact page link. -->

## Choosing scan types

`main.tf` enables every scan type. Set any of these to `false` in `datadog_agentless_scanning_aws_scan_options` to turn it off:

| Argument | Scans |
|---|---|
| `vuln_host_os` | OS packages on EC2 hosts |
| `vuln_containers_os` | Container images on hosts |
| `lambda` | Lambda functions |
| `sensitive_data` | S3 buckets for sensitive data |
| `compliance_host` | Host compliance (CIS benchmarks) |

If you turn off `sensitive_data`, you can also drop the S3 permissions from the policy with `sensitive_data_scanning_enabled = false` on the `agentless_scanning_policy` module.

## Scanning more than one account

This example enables the account your AWS provider is authenticated to. Apply it once per account (for example, one workspace or provider alias per account). Each account needs its own Datadog integration role.

## Not supported in this mode

- **Azure and GCP.** Datadog-hosted mode is AWS only.

## Versioning

The `source` in `main.tf` is pinned with `?ref=0.13.0`. Keep it pinned, and bump it deliberately when you upgrade. The latest version is in the [changelog](../../CHANGELOG.md).
