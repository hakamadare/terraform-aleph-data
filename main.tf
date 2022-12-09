terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

locals {
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "./modules/vpc"

  identifier      = var.identifier
  base_cidr_block = var.base_cidr_block
}

module "ecs" {
  source = "./modules/ecs"

  identifier      = var.identifier
  private_subnets = module.vpc.vpc.private_subnets
  vpc_id          = local.vpc_id
}

module "rds" {
  source = "./modules/rds"

  identifier             = var.identifier
  db_subnet_group_name   = module.vpc.vpc.database_subnet_group_name
  vpc_security_group_ids = []
}

