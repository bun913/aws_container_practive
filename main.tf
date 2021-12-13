terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.67.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}


module "network" {
  source = "./modules/networks"
  name   = "sbcntr-base"
}

module "container" {
  source                = "./modules/container"
  vpc_id                = module.network.vpc_id
  ingress_alb_sg        = module.network.ingress_alb_sg_id
  internal_alb_dns_name = module.network.internal_alb_dns_name
  frontend_subnet1a     = module.network.frontend_subnet1a
  frontend_subnet1c     = module.network.frontend_subnet1c
  subnet_ids = [
    module.network.backend_subnet1a,
    module.network.backend_subnet1c
  ]
  security_groups = [module.network.container_sg]
  green_target    = module.network.target_green.arn
  blue_target     = module.network.target_blue.arn
}

module "deployment" {
  source            = "./modules/deploy"
  cluster_name      = module.container.cluster_name
  service_name      = module.container.service_name
  green_listner_arn = module.network.lister_green.arn
  blue_lister_arn   = module.network.lister_blue.arn
  blue_tg_name      = module.network.target_blue.name
  greeen_tg_name    = module.network.target_green.name
}

module "databases" {
  source     = "./modules/databases"
  subnet_db1 = module.network.db_subnet1a
  subnet_db2 = module.network.db_subnet1c
  db_pass    = var.DB_INIT_PASSWORD
  db_sg      = module.network.db_sg
}

