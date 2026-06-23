output "endpoint_security_group" {
  value = aws_security_group.vpce.id
}

output "interface_endpoints" {
  value = keys(aws_vpc_endpoint.interface)
}
