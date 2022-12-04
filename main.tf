terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

locals {
  aws_region = data.aws_region.current.name
  vpc_id     = module.vpc.vpc_id
}

data "aws_region" "current" {}

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

