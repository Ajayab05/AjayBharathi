#########################################
# Existing VPC
#########################################

data "aws_vpc" "platform" {

  filter {
    name   = "tag:Name"
    values = ["platform-prod"]
  }
}

#########################################
# ALB Security Group
#########################################

resource "aws_security_group" "alb" {

  name        = "platform-alb-sg"
  description = "ALB Security Group"

  vpc_id = data.aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {

  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {

  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {

  security_group_id = aws_security_group.alb.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}

#########################################
# EKS Cluster SG
#########################################

resource "aws_security_group" "eks_cluster" {

  name        = "platform-eks-cluster-sg"
  description = "EKS Control Plane"

  vpc_id = data.aws_vpc.platform.id
}

#########################################
# Node SG
#########################################

resource "aws_security_group" "node" {

  name        = "platform-node-sg"
  description = "EKS Worker Nodes"

  vpc_id = data.aws_vpc.platform.id
}

#########################################
# Cluster <-> Node
#########################################

resource "aws_vpc_security_group_ingress_rule" "cluster_from_node" {

  security_group_id = aws_security_group.eks_cluster.id

  referenced_security_group_id = aws_security_group.node.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cluster" {

  security_group_id = aws_security_group.node.id

  referenced_security_group_id = aws_security_group.eks_cluster.id

  from_port = 1025
  to_port   = 65535

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_self" {

  security_group_id = aws_security_group.node.id

  referenced_security_group_id = aws_security_group.node.id

  from_port = 0
  to_port   = 65535

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "cluster_all" {

  security_group_id = aws_security_group.eks_cluster.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "node_all" {

  security_group_id = aws_security_group.node.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}

#########################################
# RDS SG
#########################################

resource "aws_security_group" "rds" {

  name        = "platform-rds-sg"
  description = "PostgreSQL RDS"

  vpc_id = data.aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {

  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.node.id

  from_port = 5432
  to_port   = 5432

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {

  security_group_id = aws_security_group.rds.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}




resource "aws_vpc_security_group_ingress_rule" "node_from_node_udp" {

  security_group_id = aws_security_group.node.id

  referenced_security_group_id = aws_security_group.node.id

  from_port = 0
  to_port   = 65535

  ip_protocol = "udp"
}
