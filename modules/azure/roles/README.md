<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.101.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.api_key_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.orchestrator_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.worker_role_assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.orchestrator_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.worker_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | The resource ID of the Key Vault secret holding the Datadog API key. | `string` | `null` | no |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | The object (principal) ID of the user-assigned identity used by the Datadog Agentless Scanner. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group where the Datadog Agentless Scanner exists. | `string` | n/a | yes |
| <a name="input_scan_scopes"></a> [scan\_scopes](#input\_scan\_scopes) | The set of scopes that the Datadog Agentless Scanner is allowed to scan. | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
