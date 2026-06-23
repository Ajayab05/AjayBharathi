provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "platform"
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "Platform-Team"
    }
  }
}
