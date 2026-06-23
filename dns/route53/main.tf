resource "aws_route53_zone" "primary" {

  name = var.domain_name

  comment = "Platform Production Hosted Zone"

  tags = {
    Name = var.domain_name
  }
}
