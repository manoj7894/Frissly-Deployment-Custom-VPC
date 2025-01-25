output "security_group_id" {
  value = aws_security_group.example_security_group.id
}

output "public_ip" {
  value = aws_instance.Ec2_instance_1[*].public_ip
}