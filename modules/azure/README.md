<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.13.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.101.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_custom_data"></a> [custom\_data](#module\_custom\_data) | ./custom-data | n/a |
| <a name="module_managed_identity"></a> [managed\_identity](#module\_managed\_identity) | ./managed-identity | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ./resource-group | n/a |
| <a name="module_roles"></a> [roles](#module\_roles) | ./roles | n/a |
| <a name="module_virtual_machine"></a> [virtual\_machine](#module\_virtual\_machine) | ./virtual-machine | n/a |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ./virtual-network | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource_id.api_key_id](https://registry.terraform.io/providers/Azure/azapi/1.13.1/docs/data-sources/resource_id) | data source |
| [azapi_resource_id.key_vault_id](https://registry.terraform.io/providers/Azure/azapi/1.13.1/docs/data-sources/resource_id) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/data-sources/key_vault) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ssh_key"></a> [admin\_ssh\_key](#input\_admin\_ssh\_key) | SSH public key of the admin user. | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog. | `string` | `null` | no |
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | The versionless resource ID of the Azure Key Vault secret holding the Datadog API key. Ignored if api\_key is specified. | `string` | `null` | no |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | Create a bastion in the subnet. | `bool` | `false` | no |
| <a name="input_create_roles"></a> [create\_roles](#input\_create\_roles) | Specifies whether to create the role definitions and assignments required to scan resources. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where the Datadog Agentless Scanner resources will be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Datadog Agentless Scanner resources will be created. | `string` | n/a | yes |
| <a name="input_scan_scopes"></a> [scan\_scopes](#input\_scan\_scopes) | The set of scopes that the Datadog Agentless Scanner is allowed to scan. Defaults to the current subscription. | `list(string)` | `[]` | no |
| <a name="input_site"></a> [site](#input\_site) | By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/ | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the resources created. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet"></a> [vnet](#output\_vnet) | The Azure Virtual Network created for the Datadog agentless scanner. |
<!-- END_TF_DOCS -->