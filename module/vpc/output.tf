output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "Public_subnet_id" {
  value = aws_subnet.Public.id
}

output "Private_subnet_id" {
  value = aws_subnet.Private.id
}
