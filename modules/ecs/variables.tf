variable "identifier" {
  type        = string
  description = "Unique identifier for this project."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of subnet IDs in which to provision EC2 instances for ECS cluster."
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC in which to create resources."
}
