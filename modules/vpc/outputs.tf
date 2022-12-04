output "vpc" {
  value = module.vpc
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
