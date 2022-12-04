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
}

data "aws_region" "current" {}

module "vpc" {
  source = "./modules/vpc"

  identifier      = var.identifier
  base_cidr_block = var.base_cidr_block
}
