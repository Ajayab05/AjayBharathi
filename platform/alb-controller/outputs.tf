output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "alb_policy_arn" {
  value = aws_iam_policy.alb.arn
}
