variable "ami_value" {
    description = "value for the ami"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "public_subnet_id_value" {
    description = "value for the subnet_id"
}

variable "key_name" {
    description = "key_pair value name"
}

variable "availability_zone" {
    description = "availablity_zone name"
}

variable "instance_count" {
    description = "count of instances"
}

variable "vpc_id" {
  description = "value of vpc_id"
}

variable "user_data" {
  description = "Base64 encoded user data for the instance"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Enable the public IP address"
}

variable "volume_size" {
  description = "Size of EBS volume"
}

variable "volume_type" {
  description = "Type of EBS volume"
}

variable "security_group_name" {
  description = "Name of the security group"
}

# variable "instance_tenancy" {
#     description = "The tenancy of the instance (e.g., default, dedicated, host)"
# }
