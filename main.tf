module "vpc" {
  source = "./modules/vpc"

  enable_ssm_vpc_endpoint = var.enable_ssm && var.enable_ssm_vpc_endpoint
  tags                    = var.tags
}

module "user_data" {
  source             = "./modules/user_data"
  api_key            = var.api_key
  api_key_secret_arn = var.api_key_secret_arn
  site               = var.site
  scanner_version    = var.scanner_version
}

module "instance" {
  source               = "./modules/instance"
  user_data            = module.user_data.install_sh
  iam_instance_profile = var.instance_profile_name
  subnet_id            = module.vpc.private_subnet.id
  tags                 = var.tags
}
