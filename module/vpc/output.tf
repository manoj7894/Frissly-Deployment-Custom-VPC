output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "Public_subnet_id" {
  value = aws_subnet.Public.id
}

output "Private_subnet_id" {
  value = aws_subnet.Private.id
}
