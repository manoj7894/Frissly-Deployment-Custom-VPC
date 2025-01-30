# To get the AMI
# data "aws_caller_identity" "current" {}

# # To create KMS key without adding any user
# resource "aws_kms_key" "my_kms_key" {
#   description              = "My KMS Keys for Data Encryption"
#   customer_master_key_spec = var.key_spec         #SYMMETRIC_DEFAULT
#   is_enabled               = var.enabled          # true
#   enable_key_rotation      = var.rotation_enabled # true
#   deletion_window_in_days  = 7

#   tags = {
#     Name = "my_kms_key"
#   }

#   policy = <<POLICY
# {
#     "Id": "key-consolepolicy-3",
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "Enable IAM User Permissions",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#             },
#             "Action": "kms:*",
#             "Resource": "*"
#         }
#     ]
# }
# POLICY
# }

# # To create alias for KMS
# resource "aws_kms_alias" "my_kms_alias" {
#   target_key_id = aws_kms_key.my_kms_key.key_id
#   name          = "alias/${var.kms_alias}"
# }

# Create an ECR Repository with KMS Encryption
resource "aws_ecr_repository" "demo-repository" {
  name = var.repository_name
  # encryption_configuration {
  #   encryption_type = "KMS"
  #   kms_key          = aws_kms_key.my_kms_key.arn
  # }
  image_scanning_configuration {
    scan_on_push = true
  }
}

# To attach the policy to above ECR
resource "aws_ecr_repository_policy" "demo-repo-policy" {
  repository = aws_ecr_repository.demo-repository.name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "adds full ecr access to the demo repository",
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })
}

# # Define the AWS region data source
# data "aws_region" "current" {}

# resource "aws_vpc_endpoint" "ecr_vpc_endpoint" {
#   vpc_id            = var.vpc_id  # Replace with your VPC ID
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"  # Correct reference to current region
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [var.public_subnet_id_value, var.private_subnet_id_value]  # Subnets where the VPC endpoint will be placed
#   security_group_ids = [var.security_group_id]  # Security Group for the VPC Endpoint

#   private_dns_enabled = true
# }
