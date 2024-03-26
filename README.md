# Terraform Module Datadog Agentless Scanner Module

This Terraform module provides a simple and reusable configuration for installing a Datadog agentless scanner.

## Prerequisites

Before using this module, make sure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your local machine.
2. AWS credentials configured with the necessary permissions.

## Usage

To use this module in your Terraform configuration, add the following code in your existing terraform code:
```hcl
module "scanner_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/agentless-scanner-role"

  account_roles       = [module.delegate_role.role.arn]
  api_key_secret_arns = [module.agentless_scanner.api_key_secret_arn]
}

module "delegate_role" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//modules/scanning-delegate-role"

  scanner_roles = [module.scanner_role.role.arn]
}

module "agentless_scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner"

  api_key               = "YOUR API KEY"
  instance_profile_name = module.scanner_role.instance_profile.name
}
```

And run:
```
```

> [!IMPORTANT]
> We strongly recommend [pinning](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) the version of the module to keep repeatable deployment and to avoid unexpected changes.

## Uninstall

To uninstall, remove the agentless scanner module from your Terraform code. All resources associated with the agentless scanner will be deleted. Alternatively, if you've used a separate terraform state for this setup, you can directly execute `terraform destroy`.

> [!WARNING]
> Please exercise caution when deleting Terraform resources. Review the plan carefully to ensure everything is in order.

## Examples

For complete examples, refer to the [examples](./examples/) directory in this repository.

## Development

Install pre-commit checks:

```
pre-commit install
```

Automatically generate documentation for the Terraform modules:

```
pre-commit run terraform-docs-go -a
```

Lint Terraform code:

```
pre-commit run terraform_fmt -a
pre-commit run terraform_tflint -a
```

Run all checks:

```
pre-commit run -a
```

## Changelog

See [changelog](CHANGELOG.md).
