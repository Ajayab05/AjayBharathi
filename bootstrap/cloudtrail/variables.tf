variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "platform"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "audit_bucket_name" {
  type    = string
  default = "ajay-platform-076124125794-audit"
}
