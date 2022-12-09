locals {
  major_engine_version   = split(".", var.engine_version)[0]
  family                 = "postgres${local.major_engine_version}"
  db_identifier          = "aleph"
  allocated_storage      = 5
  max_allocated_storage  = 100
  random_password_length = 64
  multi_az               = false
}

module "postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5"

  identifier = var.identifier

  engine               = "postgres"
  engine_version       = var.engine_version
  major_engine_version = local.major_engine_version
  family               = local.family

  instance_class        = "db.t4g.micro"
  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  db_name                = local.db_identifier
  username               = local.db_identifier
  create_random_password = true
  random_password_length = local.random_password_length

  multi_az = local.multi_az

  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group_name

  deletion_protection = true

  create_db_parameter_group       = true
  parameter_group_name            = var.identifier
  parameter_group_use_name_prefix = true

  vpc_security_group_ids = var.vpc_security_group_ids

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 3
  storage_encrypted       = true

  performance_insights_enabled           = true
  performance_insights_retention_period  = 7
  create_monitoring_role                 = true
  monitoring_interval                    = 60
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 3
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.identifier}/db_password"
  description = "PostgreSQL service account password for ${var.identifier}"
  type        = "SecureString"
  value       = module.postgres.db_instance_password
}
