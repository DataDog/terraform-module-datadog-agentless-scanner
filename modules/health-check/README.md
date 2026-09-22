## Description

The health-check module validates, at plan time, that the configured Datadog
`api_key` belongs to the configured `site`. It calls the Datadog `validate`
endpoint and fails the plan early on a site/key mismatch, which would otherwise
deploy a scanner that silently cannot report.

It is provided as a separate, opt-in module because it depends on the
`hashicorp/http` provider, whose data source performs an HTTP request during
`terraform plan`. Consumers that pass the API key through a secret reference
(`api_key_secret_arn`) get no value from it -- the key is never in Terraform --
and may prefer to avoid pulling the provider. The AWS/Azure/GCP root modules do
not instantiate it; add it explicitly when you pass a literal `api_key`:

```hcl
module "agentless_scanner_health_check" {
  source  = "git::https://github.com/DataDog/terraform-datadog-agentless-scanner//modules/health-check"
  site    = var.site
  api_key = var.api_key
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | The Datadog API key to validate against the configured site. When empty, the check is skipped. | `string` | `null` | no |
| <a name="input_site"></a> [site](#input\_site) | The Datadog site the API key is expected to belong to. See https://docs.datadoghq.com/getting_started/site/ | `string` | `"datadoghq.com"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
