# resource "aws_s3_bucket" "my_private_bucket" {
#   bucket_prefix = "terraform-backupfile"  # The prefix to create a unique bucket name
#   acl           = "private"  # Ensure the bucket is private

#   # Enable server-side encryption with Amazon S3 managed keys (SSE-S3)
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"  # Specifies the SSE-S3 encryption algorithm
#       }
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "my_private_bucket_access_block" {
#   bucket = aws_s3_bucket.my_private_bucket.bucket

#   block_public_acls        = true
#   ignore_public_acls        = true
#   restrict_public_buckets   = true
#   block_public_policy       = true
# }

terraform {
  backend "s3" {
    bucket  = "terraform-3003-state"
    key     = "terraform.tfstate"
    region  = "ap-south-1" # Replace with your AWS region
    encrypt = true
    # Optionally specify the DynamoDB table for state locking
    # dynamodb_table = "<YOUR_DYNAMODB_TABLE_NAME>"
  }
}