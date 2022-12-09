output "db_password_retrieval_command" {
  value = format("aws ssm get-parameter --name '%s' --with-decryption --output text --query 'Parameter.Value'", module.rds.db_password_securestring_name)
}
