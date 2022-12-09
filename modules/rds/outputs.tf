output "postgres" {
  value = module.postgres
}

output "db_password_securestring_name" {
  value = aws_ssm_parameter.db_password.name
}
