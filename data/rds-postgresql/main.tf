data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/network/vpc.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "sg" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/network/security-groups.tfstate"
    region = "us-east-1"
  }
}

data "aws_kms_alias" "rds" {
  name = "alias/platform-rds"
}

data "aws_kms_alias" "secrets" {
  name = "alias/platform-secrets"
}

resource "random_password" "db" {

  length  = 24
  special = true
}

resource "aws_secretsmanager_secret" "db" {

  name       = "platform/postgres/master"
  kms_key_id = data.aws_kms_alias.secrets.target_key_arn
}

resource "aws_secretsmanager_secret_version" "db" {

  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "platformadmin"
    password = random_password.db.result
    database = "platformdb"
  })
}

resource "aws_db_instance" "postgres" {

  identifier = "platform-postgres"

  engine         = "postgres"
  engine_version = "17.5"

  instance_class = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100

  storage_type = "gp3"

  db_name  = "platformdb"
  username = "platformadmin"
  password = random_password.db.result

  port = 5432

  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.rds.target_key_arn

  multi_az = false

  publicly_accessible = false

  backup_retention_period = 7

  performance_insights_enabled = true

  monitoring_interval = 0

  db_subnet_group_name = data.terraform_remote_state.vpc.outputs.database_subnet_group

  vpc_security_group_ids = [
    data.terraform_remote_state.sg.outputs.rds_sg_id
  ]

  skip_final_snapshot = true

  deletion_protection = false

  apply_immediately = true
}
