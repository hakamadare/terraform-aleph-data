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

  tags = {
    identifier = var.identifier
  }
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

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.18"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    lambda = {
      service             = "lambda"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      service             = "ecs-telemetry"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
    kms = {
      service             = "kms"
      private_dns_enabled = false
      subnet_ids          = module.vpc.private_subnets
    },
  }

  tags = merge(local.tags, {
    endpoint = "true"
  })
}

################################################################################
# Supporting Resources
################################################################################

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}
