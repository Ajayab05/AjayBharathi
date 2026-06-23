data "aws_kms_alias" "tfstate" {
  name = "alias/platform-tfstate"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  rule {

    bucket_key_enabled = true

    apply_server_side_encryption_by_default {

      kms_master_key_id = data.aws_kms_alias.tfstate.target_key_arn

      sse_algorithm = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  rule {

    id = "terraform-state-lifecycle"

    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
