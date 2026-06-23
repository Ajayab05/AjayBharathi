data "terraform_remote_state" "route53" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/dns/route53.tfstate"
    region = "us-east-1"
  }
}

resource "aws_acm_certificate" "wildcard" {

  domain_name = "*.ajay.bar"

  subject_alternative_names = [
    "ajay.bar"
  ]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "platform-wildcard-cert"
  }
}

resource "aws_route53_record" "validation" {

  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.terraform_remote_state.route53.outputs.hosted_zone_id

  allow_overwrite = true

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "wildcard" {

  certificate_arn = aws_acm_certificate.wildcard.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}
