output "lock_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
}

output "lock_table_arn" {
  value = aws_dynamodb_table.terraform_lock.arn
}
