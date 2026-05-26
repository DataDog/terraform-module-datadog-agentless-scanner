<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.101.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.101.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_monitor_autoscale_setting.autoscale_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [random_integer.restart_minute](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [azapi_resource_list.vm_skus](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_list) | data source |
| [azapi_resource_list.vm_usages](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_list) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ssh_key"></a> [admin\_ssh\_key](#input\_admin\_ssh\_key) | SSH public key for the admin user | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Name of the admin user to use for the instance | `string` | `"azureuser"` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | The user data to provide when launching the instance | `string` | `null` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | Ubuntu 24.04 LTS image SKU to use for the scanner VMSS. When null<br>(default), the module picks "minimal-arm64" for ARM SKUs and "minimal"<br>for x86 SKUs. Set explicitly to use a custom Ubuntu SKU; in that case<br>you must also set instance\_size to a matching architecture. | `string` | `null` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Size of the scale set the scanner instance is in (i.e. number of instances to run) | `number` | `1` | no |
| <a name="input_instance_root_volume_size"></a> [instance\_root\_volume\_size](#input\_instance\_root\_volume\_size) | The instance root volume size in GiB | `number` | `30` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | The VM SKU to use for the scanner VMSS. When null (default), the module<br>auto-selects from a 3-tier fallback chain based on what is available in<br>the target region:<br>  1. Standard\_B2ps\_v2  (ARM Burstable, cheapest, major regions)<br>  2. Standard\_D2pls\_v6 (ARM v6 D-series, modern ARM-capable regions)<br>  3. Standard\_D2s\_v3   (x86 D-series, universal fallback for regions<br>                        without ARM availability, e.g. qatarcentral)<br>Set this explicitly to bypass auto-selection. When overriding to an x86<br>SKU, also set image\_sku to a non-arm64 Ubuntu SKU (e.g. "minimal"). | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of the resource group where the Datadog Agentless Scanner network resources will be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix to be used on EC2 instance created | `string` | `"DatadogAgentlessScanner"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Datadog Agentless Scanner network resources will be created | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet to launch in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the instance/volume created | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | The resource ID of the managed identity to be assigned to the Datadog Agentless Scanner virtual machine instances | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->