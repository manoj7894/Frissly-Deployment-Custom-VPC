# To create the Ec2 instance
resource "aws_instance" "Ec2_instance_1" {
  ami                         = var.ami_value           # Change to your desired AMI ID
  instance_type               = var.instance_type_value # Change to your desired instance type
  subnet_id                   = var.public_subnet_id_value
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = aws_key_pair.key_pair.key_name # Change to your key pair name
  availability_zone           = var.availability_zone
  count                       = var.instance_count
  vpc_security_group_ids      = [aws_security_group.example_security_group.id]
  # tenancy                     = var.instance_tenancy    # Specify dedicated tenancy


  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "Frissly-Instance-${count.index}"
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096-example.public_key_openssh
}

resource "local_file" "private_key" {
  content = tls_private_key.rsa-4096-example.private_key_pem
  filename = var.key_name
}

# Create a security group
resource "aws_security_group" "example_security_group" {
  name_prefix = var.security_group_name
  description = "Example security group"
  vpc_id      = var.vpc_id

  # Define your security group rules as needed
  # For example, allow SSH and HTTP traffic
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPs access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "jenkins access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "sonarqube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}