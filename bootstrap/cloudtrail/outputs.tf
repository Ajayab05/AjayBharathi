output "cloudtrail_bucket" {
  value = aws_s3_bucket.audit.bucket
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.main.arn
}
