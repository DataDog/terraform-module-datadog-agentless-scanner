<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.101.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/3.101.0/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location where the Datadog Agentless Scanner resources will be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances | `string` | `"DatatogAgentlessScanner"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to which the role assignment will be scoped | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the managed identity will be created | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the managed identity | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances |
<!-- END_TF_DOCS -->