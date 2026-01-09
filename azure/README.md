# Terraform Module Datadog Agentless Scanner for Azure

This Terraform module provides a simple and reusable configuration for installing a Datadog Agentless Scanner on Azure.

For more information about Agentless Scanning, see the [Datadog Agentless Scanning documentation](https://docs.datadoghq.com/security/cloud_security_management/agentless_scanning/).

## Prerequisites

Before using this module, make sure you have the following:

1. [Terraform](https://www.terraform.io/) installed on your local machine.
2. The [Azure CLI](https://learn.microsoft.com/cli/azure/) installed on your local machine.
3. Azure credentials configured (`az login`) with the necessary permissions.

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

### Notes

- `site` must match the Datadog site parameter of your account (see [this table](https://docs.datadoghq.com/getting_started/site/#access-the-datadog-site)).
- `location` must be an Azure region. To avoid inter-region bandwidth charges,
  the scanner should be deployed in the same region as the resources to be scanned.
- `resource_group_name` is the name of the resource group where the Agentless scanner
  is created. For security reasons, this resource group should be reserved for
  the exclusive use of the scanner.
- `scan_scopes` is a list of [scopes](https://learn.microsoft.com/azure/role-based-access-control/scope-overview)
  that the Agentless scanner should scan. The scanner is given read access to managed
  disks in these scopes. Only subscription scopes are supported.


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
