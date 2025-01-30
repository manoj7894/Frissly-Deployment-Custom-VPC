variable "app_runner_service_name" {
  default = "name of the service"
}

variable "image_repository_type" {
  description = "Type of ECR"
}

variable "port" {
  description = "Port Number of the application"
}

variable "cpu" {
  description = "CPU value"
}

variable "memory" {
  description = "Memory value"
}

variable "auto_deployments_enabled" {
  description = "Set up the Auto Deployment Option"
}

variable "repository_name" {
  description = "name of the ECR Repository"
}

variable "image_tag" {
  description = "Tag of the ECR Image"
}

variable "auto_scaling_configuration_name" {
  description = "Name of the Autoscaling"
}

variable "max_concurrency" {
  description = "max_concurrency of the requests"
}

variable "min_size" {
  description = "minumum number of Instances"
}

variable "max_size" {
  description = "maximum number of Instances"
}

variable "interval" {
  description = "Health check intervel"
}

variable "timeout" {
  description = "Health check timeout"
}

variable "healthy_threshold" {
  description = "Instace healthy threshold"
}

variable "unhealthy_threshold" {
  description = "Instace unhealthy threshold"
}

variable "protocol" {
  description = "Network protocal of instance"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# variable "public_subnet_id_value" {
#   description = "Public subnet ID for EFS mount target"
#   type        = string
# }

variable "private_subnet_id_value" {
  description = "Private subnet ID for EFS mount target"
  type        = string
}

variable "security_group_name" {
  description = "Give apprunner security group"
}

variable "role_name" {
  description = "Appruner IAM role"
}

variable "policy_name" {
  description = "give apprunner policy name"
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}