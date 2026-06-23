output "terraform_execution_role_arn" {
  value = aws_iam_role.terraform_execution.arn
}

output "platform_admin_role_arn" {
  value = aws_iam_role.platform_admin.arn
}

output "readonly_role_arn" {
  value = aws_iam_role.readonly.arn
}
