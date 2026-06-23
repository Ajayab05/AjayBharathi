locals {
  kms_keys = {
    tfstate = "Terraform State Encryption"
    rds     = "RDS Encryption"
    secrets = "Secrets Manager Encryption"
    logs    = "CloudWatch Logs Encryption"
    backup  = "Backup Encryption"
  }
}

resource "aws_kms_key" "keys" {

  for_each = local.kms_keys

  description             = each.value
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = each.key
  }
}

resource "aws_kms_alias" "aliases" {

  for_each = aws_kms_key.keys

  name = "alias/platform-${each.key}"

  target_key_id = each.value.key_id
}
