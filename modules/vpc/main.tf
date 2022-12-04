terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

locals {
  availability_zone_names = slice(data.aws_availability_zones.azs.names, 0, var.az_limit)

  public_cidrs      = [for i, _ in local.availability_zone_names : cidrsubnet(var.base_cidr_block, 8, i)]
  private_cidrs     = [for i, _ in local.availability_zone_names : cidrsubnet(var.base_cidr_block, 8, i + 10)]
  database_cidrs    = [for i, _ in local.availability_zone_names : cidrsubnet(var.base_cidr_block, 8, i + 100)]
  elasticache_cidrs = [for i, _ in local.availability_zone_names : cidrsubnet(var.base_cidr_block, 8, i + 150)]

}

data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.18"

  name = var.identifier
  cidr = var.base_cidr_block

  azs                 = local.availability_zone_names
  public_subnets      = local.public_cidrs
  private_subnets     = local.private_cidrs
  database_subnets    = local.database_cidrs
  elasticache_subnets = local.elasticache_cidrs

  public_subnet_tags      = { tier = "public" }
  private_subnet_tags     = { tier = "private" }
  database_subnet_tags    = { tier = "database" }
  elasticache_subnet_tags = { tier = "elasticache" }

  enable_nat_gateway = true
  single_nat_gateway = true

  create_database_subnet_group    = true
  create_elasticache_subnet_group = true

  tags = {
    identifier = var.identifier
  }

}
