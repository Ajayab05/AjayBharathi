provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "platform"
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "Platform-Team"
    }
  }
}
