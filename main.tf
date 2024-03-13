module "vpc" {
  source                  = "./modules/vpc"
  enable_ssm_vpc_endpoint = var.enable_ssm && var.enable_ssm_vpc_endpoint
  tags                    = var.tags
}

module "user_data" {
  source             = "./modules/user_data"
  api_key            = var.api_key
  api_key_secret_arn = var.api_key_secret_arn
  site               = var.site
  tags               = var.tags
}

module "instance" {
  source               = "./modules/instance"
  user_data            = module.user_data.install_sh
  vpc_id               = module.vpc.vpc.id
  subnet_ids           = [for s in module.vpc.private_subnets : s.id]
  iam_instance_profile = var.instance_profile_name
  tags                 = var.tags

  depends_on = [module.vpc.routing_ready]
}
