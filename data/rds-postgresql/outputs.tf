output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}
