data "aws_caller_identity" "current" {}

data "aws_kms_alias" "logs" {
  name = "alias/platform-logs"
}

########################################
# Audit Bucket
########################################

resource "aws_s3_bucket" "audit" {
  bucket = var.audit_bucket_name
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {

  bucket = aws_s3_bucket.audit.id

  rule {

    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.logs.target_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

########################################
# CloudWatch Log Group
########################################
resource "aws_cloudwatch_log_group" "cloudtrail" {

  name              = "/aws/cloudtrail/platform"
  retention_in_days = 365
}
########################################
# IAM Role
########################################

resource "aws_iam_role" "cloudtrail" {

  name = "platform-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail" {

  name = "platform-cloudtrail-policy"
  role = aws_iam_role.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

########################################
# Bucket Policy
########################################

resource "aws_s3_bucket_policy" "cloudtrail" {

  bucket = aws_s3_bucket.audit.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:GetBucketAcl"

        Resource = aws_s3_bucket.audit.arn
      },

      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.audit.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

########################################
# CloudTrail
########################################

resource "aws_cloudtrail" "main" {

  name = "platform-cloudtrail"

  s3_bucket_name = aws_s3_bucket.audit.id

  include_global_service_events = true

  is_multi_region_trail = true

  enable_log_file_validation = true


  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"

  cloud_watch_logs_role_arn = aws_iam_role.cloudtrail.arn

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}



resource "aws_s3_bucket_lifecycle_configuration" "audit" {

  bucket = aws_s3_bucket.audit.id

  rule {
    id     = "audit-retention"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}
