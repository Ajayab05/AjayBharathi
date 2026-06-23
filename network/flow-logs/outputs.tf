output "flow_log_id" {
  value = aws_flow_log.vpc.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.flowlogs.name
}
