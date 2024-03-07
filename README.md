# Terraform Module Datadog Agentless Scanner Module

This Terraform module provides a simple and reusable configuration for installing a Datadog agentless scanner.

## Prerequisites

Before using this module, make sure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your local machine.
2. AWS credentials configured with the necessary permissions.

## Usage

To use this module in your Terraform configuration, add the following code:

```hcl
module "agentless_scanner" {
  source = "github.com/DataDog/terraform-module-datadog-agentless-scanner"

  api_key               = "YOUR_API_KEY"
  instance_profile_name = ""
}
```

## Example

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
