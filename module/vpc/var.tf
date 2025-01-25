variable "vpc_id" {
  description = "value of vpc_id"
}

variable "public_subnet_id_value" {
    description = "value for the subnet_id"
}

variable "availability_zone" {
    description = "availablity_zone name"
}

variable "private_subnet_id_value" {
    description = "value for the subnet_id"
}

variable "availability_zone1" {
    description = "availablity_zone name"
}

variable "instance_tenancy" {
  description = "tenancy model of the instances"
}

variable "enable_dns_support" {
  description = "Indicates whether DNS resolution is supported in the VPC."
}

variable "enable_dns_hostnames" {
  description = "Determines whether DNS hostnames are assigned to instances launched in the VPC"
}

variable "map_public_ip_on_launch" {
  description = "Enable the Public Ip"
}