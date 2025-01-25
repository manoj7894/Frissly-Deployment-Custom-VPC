output "apprunner_service_role_arn" {
  description = "The ARN of the App Runner service role"
  value       = aws_iam_role.apprunner_service_role.arn
}