data "azurerm_subscription" "current" {}

data "azapi_resource_id" "api_key_id" {
  count       = var.api_key == null ? 1 : 0
  type        = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  resource_id = var.api_key_secret_id
}

data "azapi_resource_id" "key_vault_id" {
  count       = length(data.azapi_resource_id.api_key_id)
  type        = "Microsoft.KeyVault/vaults@2023-07-01"
  resource_id = data.azapi_resource_id.api_key_id[count.index].parent_id
}

data "azurerm_key_vault" "key_vault" {
  count               = length(data.azapi_resource_id.key_vault_id)
  name                = data.azapi_resource_id.key_vault_id[count.index].name
  resource_group_name = data.azapi_resource_id.key_vault_id[count.index].resource_group_name
}

locals {
  api_key_uri = var.api_key != null ? null : "${data.azurerm_key_vault.key_vault[0].vault_uri}secrets/${data.azapi_resource_id.api_key_id[0].name}"
}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source              = "./modules/virtual-network"
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  bastion             = var.bastion
  tags                = var.tags
}

module "custom_data" {
  source                = "./modules/custom-data"
  api_key               = var.api_key != null ? var.api_key : "@Microsoft.KeyVault(SecretUri=${local.api_key_uri})"
  scanner_channel       = var.scanner_channel
  scanner_version       = var.scanner_version
  scanner_repository    = var.scanner_repository
  scanner_configuration = var.scanner_configuration
  agent_configuration   = var.agent_configuration
  site                  = var.site
  client_id             = module.managed_identity.identity.client_id
}

module "managed_identity" {
  source              = "./modules/managed-identity"
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  tags                = var.tags
}

module "roles" {
  count             = var.create_roles ? 1 : 0
  source            = "./modules/roles"
  resource_group_id = module.resource_group.resource_group.id
  principal_id      = module.managed_identity.identity.principal_id
  api_key_secret_id = one(data.azapi_resource_id.api_key_id[*].resource_id)
  scan_scopes       = coalescelist(var.scan_scopes, [data.azurerm_subscription.current.id])
}

module "virtual_machine" {
  source                 = "./modules/virtual-machine"
  depends_on             = [module.virtual_network]
  location               = var.location
  resource_group_name    = module.resource_group.resource_group.name
  admin_ssh_key          = var.admin_ssh_key
  instance_count         = var.instance_count
  custom_data            = module.custom_data.install_sh
  subnet_id              = module.virtual_network.subnet.id
  user_assigned_identity = module.managed_identity.identity.id
  tags                   = var.tags
}
