variable "key_spec" {
  default = "SYMMETRIC_DEFAULT"
}

variable "enabled" {
  default = true
}

variable "rotation_enabled" {
  default = true
}

variable "kms_alias" {
  default = "demo"
}

# variable "vpc_id" {
#   description = "The ID of the VPC"
#   type        = string
# }

# variable "public_subnet_id_value" {
#     description = "value for the subnet_id"
# }

# variable "private_subnet_id_value" {
#     description = "value for the subnet_id"
# }

# variable "security_group_id" {
#   description = "Security group ID for EFS"
#   type        = string
# }

variable "repository_name" {
  description = "name of the ECR repository"
}