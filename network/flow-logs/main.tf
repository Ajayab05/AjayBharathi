#####################################
# Existing VPC
#####################################

data "aws_vpc" "platform" {

  filter {
    name   = "tag:Name"
    values = ["platform-prod"]
  }
}

#####################################
# CloudWatch Log Group
#####################################

resource "aws_cloudwatch_log_group" "flowlogs" {

  name              = "/aws/vpc/platform-prod-flowlogs"
  retention_in_days = 365

  lifecycle {
    prevent_destroy = true
  }
}
#####################################
# IAM Role
#####################################

resource "aws_iam_role" "flowlogs" {

  name = "platform-vpc-flowlogs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

#####################################
# IAM Policy
#####################################

resource "aws_iam_role_policy" "flowlogs" {

  name = "platform-vpc-flowlogs-policy"

  role = aws_iam_role.flowlogs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "*"
      }
    ]
  })
}

#####################################
# VPC Flow Logs
#####################################

resource "aws_flow_log" "vpc" {

  iam_role_arn = aws_iam_role.flowlogs.arn

  log_destination_type = "cloud-watch-logs"

  log_destination = aws_cloudwatch_log_group.flowlogs.arn

  traffic_type = "ALL"

  vpc_id = data.aws_vpc.platform.id

  max_aggregation_interval = 60
}
