<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.template](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Specifies the API key required by the Datadog Agent to submit vulnerabilities to Datadog | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the resource group where the Datadog Agentless Scanner resources will be created | `string` | n/a | yes |
| <a name="input_site"></a> [site](#input\_site) | By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/ | `string` | `"datadoghq.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_version"></a> [agent\_version](#output\_agent\_version) | The version of the Datadog Agent installed |
| <a name="output_install_sh"></a> [install\_sh](#output\_install\_sh) | The installation script for the Datadog agentless scanner |
| <a name="output_scanner_version"></a> [scanner\_version](#output\_scanner\_version) | The version of the Datadog Agentless Scanner installed |
<!-- END_TF_DOCS -->
