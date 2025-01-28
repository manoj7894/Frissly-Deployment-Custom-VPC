# Create a security group
resource "aws_security_group" "app_runner_security_group" {
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
    cidr_blocks = ["172.0.0.0/16"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/16"]
  }

  ingress {
    description = "HTTPs access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/16"]
  }

  # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "jenkins access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/16"]
  }

    # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "AppRunner access"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/16"]
  }

  # Allow HTTP access (port 8080) for Jenkins web interface
  ingress {
    description = "sonarqube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/16"]
  }

  # outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apprunner_vpc_connector" "vpc_connector" {
  vpc_connector_name = "vpc_connector"
  subnets            = [var.private_subnet_id_value]
  security_groups    = [aws_security_group.app_runner_security_group.id]
}



# To create apprunner with Private ECR image
# Define the IAM role
resource "aws_iam_role" "apprunner_service_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "time_sleep" "waitrolecreate" {
  depends_on      = [aws_iam_role.apprunner_service_role]
  create_duration = "60s"
}

# Define the IAM policy
resource "aws_iam_policy" "apprunner_policy" {
  name        = var.policy_name
  description = "IAM policy for AWS App Runner service with ECR, CloudWatch Logs, and Secrets Manager permissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "apprunner_service_policy_attachment" {
  role       = aws_iam_role.apprunner_service_role.name
  policy_arn = aws_iam_policy.apprunner_policy.arn
}


# Create an App Runner Auto Scaling Configuration
resource "aws_apprunner_auto_scaling_configuration_version" "autoscaling_config" {
  auto_scaling_configuration_name = var.auto_scaling_configuration_name

  # Set minimum and maximum concurrency values
  max_concurrency         = var.max_concurrency
  min_size                = var.min_size
  max_size                = var.max_size
}

# 3. Data block to reference an existing ECR repository and image
data "aws_ecr_repository" "repo" {
  name = var.repository_name
}

data "aws_ecr_image" "repo" {
  repository_name = data.aws_ecr_repository.repo.name
  image_tag       = var.image_tag
}


resource "aws_apprunner_service" "backend" {
  service_name = var.app_runner_service_name

  source_configuration {
    image_repository {
      image_configuration {
        port = var.port
      }
      image_identifier = "${data.aws_ecr_repository.repo.repository_url}:latest" # Use the latest tag or replace with your tag
      image_repository_type = var.image_repository_type
    }
    auto_deployments_enabled = var.auto_deployments_enabled
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_service_role.arn
    }
  }

  instance_configuration {
    cpu    = var.cpu # 1 vCPU
    memory = var.memory # 2 GB RAM
  }

  health_check_configuration {
    # path                = "/"
    interval            = var.interval
    timeout             = var.timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    protocol            = var.protocol           # Give TCP or HTTP no problem
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.vpc_connector.arn
    }
  }

   # Associate the Auto Scaling Configuration
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.autoscaling_config.id

  tags = {
    Name = "example-apprunner-service"
  }
}