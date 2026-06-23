#################################################
# Existing VPC
#################################################

data "aws_vpc" "platform" {

  filter {
    name   = "tag:Name"
    values = ["platform-prod"]
  }
}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.platform.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

#################################################
# Endpoint Security Group
#################################################

resource "aws_security_group" "vpce" {

  name        = "platform-vpc-endpoints-sg"
  description = "Security Group for Interface Endpoints"
  vpc_id      = data.aws_vpc.platform.id

  ingress {
    description = "HTTPS"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.platform.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################################################
# S3 Gateway Endpoint
#################################################

resource "aws_vpc_endpoint" "s3" {

  vpc_id            = data.aws_vpc.platform.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = data.aws_route_tables.private.ids
}

#################################################
# Route Tables
#################################################

data "aws_route_tables" "private" {

  vpc_id = data.aws_vpc.platform.id

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

#################################################
# Interface Endpoints
#################################################

locals {

  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "logs",
    "secretsmanager",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "ec2"
  ]
}

resource "aws_vpc_endpoint" "interface" {

  for_each = toset(local.interface_endpoints)

  vpc_id = data.aws_vpc.platform.id

  service_name = "com.amazonaws.${var.aws_region}.${each.value}"

  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = data.aws_subnets.private.ids

  security_group_ids = [
    aws_security_group.vpce.id
  ]
}
