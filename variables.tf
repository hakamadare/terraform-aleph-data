variable "az_limit" {
  type        = number
  description = "Number of availability zones over which to deploy (must be >=2)."
  default     = 2

  validation {
    condition     = var.az_limit >= 2
    error_message = "The az_limit value must be an integer >=2."
  }
}

variable "base_cidr_block" {
  type        = string
  description = "Base network block for VPC, in CIDR format; must have a /16 suffix."
  default     = "10.0.0.0/16"

  validation {
    condition     = endswith(var.base_cidr_block, "/16")
    error_message = "The base_cidr_block value must end with the suffix /16."
  }
}

variable "identifier" {
  type        = string
  description = "Unique identifier for this project."
}
