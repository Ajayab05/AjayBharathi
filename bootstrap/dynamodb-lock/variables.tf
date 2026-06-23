variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "platform"
}

variable "environment" {
  type        = string
  description = "Environment"
  default     = "prod"
}

variable "lock_table_name" {
  type        = string
  description = "Terraform Lock Table Name"
  default     = "platform-prod-terraform-lock"
}
