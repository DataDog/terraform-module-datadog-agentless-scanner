# Terraform Module Datadog Agentless Scanner for Azure

This Terraform module provides a simple and reusable configuration for installing a Datadog Agentless Scanner on Azure.

For more information about Agentless Scanning, see the [Datadog Agentless Scanning documentation](https://docs.datadoghq.com/security/cloud_security_management/agentless_scanning/).

## Prerequisites

Before using this module, make sure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your local machine.
2. The [Azure CLI](https://learn.microsoft.com/cli/azure/) installed on your local machine.
3. Azure credentials configured (`az login`) with the necessary permissions.
4. A Datadog [API key](https://docs.datadoghq.com/account_management/api-app-keys/) with Remote Configuration enabled.

## Usage

To use this module in your Terraform configuration, add the following code in your existing Terraform code:

```hcl
variable "datadog-api-key" {}

module "datadog-agentless-scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//azure"

  site                = "datadoghq.com"
  location            = "East US"
  resource_group_name = "datadog-agentless-scanner"
  admin_ssh_key       = "ssh-rsa ..." # SSH public key of the admin user
  api_key             = var.datadog-api-key

  # A list of subscriptions to be scanned. If not specified, defaults to the current subscription.
  scan_scopes = ["/subscriptions/00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
}
```

And run:
```sh
terraform init
export ARM_SUBSCRIPTION_ID="00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
terraform apply -var="datadog-api-key=$DD_API_KEY"
```

### Configuration Notes

- **`site`**: Must match the Datadog site parameter of your account. Common values: `datadoghq.com`, `datadoghq.eu`, `us3.datadoghq.com`, `us5.datadoghq.com`, `ap1.datadoghq.com`. See [Datadog site documentation](https://docs.datadoghq.com/getting_started/site/#access-the-datadog-site).
- **`location`**: Must be an Azure region. To avoid inter-region bandwidth charges, the scanner should be deployed in the same region as the resources to be scanned.
- **`resource_group_name`**: The name of the resource group where the Agentless scanner is created. For security reasons, this resource group should be reserved for the exclusive use of the scanner.
- **`scan_scopes`**: A list of [scopes](https://learn.microsoft.com/azure/role-based-access-control/scope-overview) that the Agentless scanner should scan. The scanner is given read access to managed disks in these scopes. Only subscription scopes are supported.

> [!IMPORTANT]
> Datadog strongly recommends [pinning](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) the version of the module to keep repeatable deployment and to avoid unexpected changes. Use a specific tag instead of a branch name.

### API Key Configuration

You have two options for providing the Datadog API key:

1. **Pass the API key directly** (shown in examples above):
   ```hcl
   api_key = var.datadog-api-key
   ```

2. **Use Azure Key Vault** (recommended for production):
   - Create a secret in Azure Key Vault containing your Datadog API key
   - Use the secret ID instead:
   ```hcl
   api_key_secret_id = "/subscriptions/00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/my-rg/providers/Microsoft.KeyVault/vaults/my-vault/secrets/datadog-api-key"
   ```
   - Note: When using `api_key_secret_id`, omit the `api_key` variable

### Cross-Subscription Scanning

To scan multiple subscriptions from a single scanner deployment:

```hcl
module "datadog-agentless-scanner" {
  source = "git::https://github.com/DataDog/terraform-module-datadog-agentless-scanner//azure?ref=0.11.12"

  # ... other configuration ...

  scan_scopes = [
    "/subscriptions/00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx",  # Subscription A
    "/subscriptions/11111111-xxxx-xxxx-xxxx-xxxxxxxxxxxx",  # Subscription B
    "/subscriptions/22222222-xxxx-xxxx-xxxx-xxxxxxxxxxxx",  # Subscription C
  ]
}
```

The scanner will be granted the necessary role assignments in each subscription to read and scan managed disks.

## Architecture

The Agentless Scanner deployment on Azure is split into different modules to allow for more flexibility and customization:

- **[resource-group](./modules/resource-group/)**: Creates the resource group where all scanner resources are deployed.
- **[managed-identity](./modules/managed-identity/)**: Creates the user-assigned managed identity for the scanner VM.
- **[roles](./modules/roles/)**: Creates the custom role definitions and role assignments required for scanning.
- **[virtual-network](./modules/virtual-network/)**: Creates the VNet, subnet, NAT gateway, and network security group.
- **[virtual-machine](./modules/virtual-machine/)**: Creates the Virtual Machine Scale Set (VMSS) that runs the scanner.
- **[custom-data](./modules/custom-data/)**: Generates the cloud-init script that installs and configures the scanner.

The main module provided in this directory is a wrapper around these modules with simplified inputs.

## Uninstall

To uninstall, remove the Agentless scanner module from your Terraform code. Removing this module deletes all resources associated with the Agentless scanner. Alternatively, if you used a separate Terraform state for this setup, you can uninstall the Agentless scanner by executing `terraform destroy`.

> [!WARNING]
> Exercise caution when deleting Terraform resources. Review the plan carefully to ensure everything is in order.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.13.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.101.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_custom_data"></a> [custom\_data](#module\_custom\_data) | ./modules/custom-data | n/a |
| <a name="module_managed_identity"></a> [managed\_identity](#module\_managed\_identity) | ./modules/managed-identity | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ./modules/resource-group | n/a |
| <a name="module_roles"></a> [roles](#module\_roles) | ./modules/roles | n/a |
| <a name="module_virtual_machine"></a> [virtual\_machine](#module\_virtual\_machine) | ./modules/virtual-machine | n/a |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ./modules/virtual-network | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource_id.api_key_id](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_id) | data source |
| [azapi_resource_id.key_vault_id](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_id) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ssh_key"></a> [admin\_ssh\_key](#input\_admin\_ssh\_key) | SSH public key of the admin user. | `string` | n/a | yes |
| <a name="input_agent_configuration"></a> [agent\_configuration](#input\_agent\_configuration) | Specifies a custom configuration for the Datadog Agent. The specified object is passed directly as a configuration input for the Datadog Agent. | `any` | `{}` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Specifies the API key required by the Agentless Scanner to submit vulnerabilities to Datadog - Make sure the API key is Remote Configuration enabled. | `string` | `null` | no |
| <a name="input_api_key_secret_id"></a> [api\_key\_secret\_id](#input\_api\_key\_secret\_id) | The versionless resource ID of the Azure Key Vault secret holding the Datadog API key. Ignored if api\_key is specified - Make sure the API key is Remote Configuration enabled. | `string` | `null` | no |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | Create a bastion in the subnet. | `bool` | `false` | no |
| <a name="input_create_roles"></a> [create\_roles](#input\_create\_roles) | Specifies whether to create the role definitions and assignments required to scan resources. | `bool` | `true` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Size of the scale set the scanner instance is in (i.e. number of instances to run) | `number` | `1` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where the Datadog Agentless Scanner resources will be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Datadog Agentless Scanner resources will be created. | `string` | n/a | yes |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | Prefix to use for custom role names. Used to create 'Orchestrator Role' and 'Worker Role'. | `string` | `"Datadog Agentless Scanner"` | no |
| <a name="input_scan_scopes"></a> [scan\_scopes](#input\_scan\_scopes) | The set of scopes that the Datadog Agentless Scanner is allowed to scan. Defaults to the current subscription. | `list(string)` | `[]` | no |
| <a name="input_scanner_channel"></a> [scanner\_channel](#input\_scanner\_channel) | Channel of the scanner to install from (stable or beta). | `string` | `"stable"` | no |
| <a name="input_scanner_configuration"></a> [scanner\_configuration](#input\_scanner\_configuration) | Specifies a custom configuration for the scanner. The specified object is passed directly as a configuration input for the scanner. | `any` | `{}` | no |
| <a name="input_scanner_repository"></a> [scanner\_repository](#input\_scanner\_repository) | Repository URL to install the scanner from. | `string` | `"https://apt.datadoghq.com/"` | no |
| <a name="input_scanner_version"></a> [scanner\_version](#input\_scanner\_version) | Version of the scanner to install | `string` | `"0.11"` | no |
| <a name="input_site"></a> [site](#input\_site) | By default the Agent sends its data to Datadog US site. If your organization is on another site, you must update it. See https://docs.datadoghq.com/getting_started/site/ | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to the resources created. | `map(string)` | `{}` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | The CIDR block for the Virtual Network | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet"></a> [vnet](#output\_vnet) | The Azure Virtual Network created for the Datadog agentless scanner. |
<!-- END_TF_DOCS -->
