# 1. Create an SNS Topic
resource "aws_sns_topic" "app_runner_notifications" {
  name                        = var.sns_name
  display_name                = var.display_name
  fifo_topic                  = false
  content_based_deduplication = false
}

# 2. Create an SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.app_runner_notifications.arn
  protocol  = var.protocol
  endpoint  = var.endpoint # Replace with your email address
}

# 4. Create EventBridge Rule for App Runner Deployment Events
resource "aws_cloudwatch_event_rule" "app_runner_event_rule" {
  name        = var.eventbridge_name
  description = "Triggers on App Runner deployment success or failure"
  event_pattern = jsonencode({
    source      = ["aws.apprunner"]
    "detail-type" = ["AppRunner Service Operation Status Change"]
    detail = {
      operationStatus = ["DeploymentCompletedSuccessfully", "DeploymentFailed"]
    }
  })
}

# 5. Add SNS Topic as Target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.app_runner_event_rule.name
  arn       = aws_sns_topic.app_runner_notifications.arn
}

# 6. IAM Role for EventBridge to Publish to SNS
resource "aws_iam_role" "eventbridge_to_sns_role" {
  name = var.eventbridge_to_sns_role_name

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# 7. Add Policy to Allow EventBridge to Publish to SNS
resource "aws_iam_policy" "sns_publish_policy" {
  name = var.sns_publish_policy_name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": aws_sns_topic.app_runner_notifications.arn
      }
    ]
  })
}

# 8. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_sns_policy" {
  role       = aws_iam_role.eventbridge_to_sns_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}
