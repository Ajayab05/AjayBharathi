output "kms_keys" {
  value = {
    for k, v in aws_kms_key.keys :
    k => {
      arn = v.arn
      id  = v.key_id
    }
  }
}
