# Cross Account Example

This folder shows an example of Terraform code that uses the [datadog-agentless-scanner module](https://github.com/Datadog/terraform-module-datadog-agentless-scanner) to deploy a Datadog agentless scanner in a main [AWS](https://aws.amazon.com/) account and cross account role in your other accounts.

In this example the full scanner setup is deployed in a single account dedicated for the scanning purpose.
All your other accounts can be scanned from that account by deploying a single IAM role.


## Quick start

To deploy a Datadog agentless scanner:

1. Go to the `scanner_account` folder
1. Run `terraform init`.
1. Run `terraform apply`.
1. Set your Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/).
1. You can leave the `cross_account_delegate_arn` variable empty for now.
1. Run `terraform output scanner_role` and copy that ARN.

To deploy the delegate role:

1. Go to the `other_account` folder
1. Run `terraform init`.
1. Run `terraform apply`.
1. Set the ARN of the scanner role you got from the previous step.
1. Run `terraform output delegate_role` and copy that ARN

Finally since cross account delegate role need bi-directional permission:

1. Go back to the `scanner_account` folder
1. Run `terraform apply`.
1. Set the ARN of the delegate role you created in your other account.
