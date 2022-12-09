variable "identifier" {
  type        = string
  description = "Unique identifier for this project."
}

variable "engine_version" {
  type        = string
  description = "RDS PostgreSQL engine version (`aws rds describe-db-engine-versions --engine postgres --query 'DBEngineVersions[].EngineVersion'` to identify valid values)"
  default     = "14.5"

  validation {
    condition     = can(regex("^(?:[[:digit:]]+\\.)+[[:digit:]]+$", var.engine_version))
    error_message = "The engine_version value must consist of digits, delimited by periods."
  }
}

variable "db_subnet_group_name" {
  type        = string
  description = "RDS subnet group name"

  validation {
    condition     = can(regex("^[[:lower:][:digit:]-]{1,255}$", var.db_subnet_group_name))
    error_message = "The db_subnet_group_name value must consist of alphanumeric characters and hyphens, no more than 255 characters in length."
  }
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "VPC security group IDs to be granted access to the database"

  validation {
    condition     = alltrue([for id in var.vpc_security_group_ids : startswith(id, "sg-")])
    error_message = "All elements in the vpc_security_group_ids list must begin with 'sg-'."
  }
}
