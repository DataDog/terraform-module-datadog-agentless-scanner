module "resource_group" {
  source   = "./modules/azure/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source              = "./modules/azure/virtual-network"
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  tags                = var.tags
}

module "custom_data" {
  source   = "./modules/azure/custom-data"
  location = var.location
  api_key  = var.api_key
  site     = var.site
  tags     = var.tags
}

module "managed_identity" {
  source              = "./modules/azure/managed-identity"
  resource_group_name = module.resource_group.resource_group.name
  resource_group_id   = module.resource_group.resource_group.id
  location            = var.location
  tags                = var.tags
}

module "virtual_machine" {
  source                 = "./modules/azure/virtual-machine"
  location               = var.location
  resource_group_name    = module.resource_group.resource_group.name
  admin_ssh_key          = var.admin_ssh_key
  custom_data            = module.custom_data.install_sh
  subnet_id              = module.virtual_network.subnet.id
  user_assigned_identity = module.managed_identity.identity.id
  tags                   = var.tags
}
