module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-${var.environment}"

  cidr = var.vpc_cidr

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  database_subnets = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false

  enable_flow_log                    = false
  create_database_subnet_route_table = true
  enable_vpn_gateway                 = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/platform-prod" = "shared"
  }

  private_subnet_tags = {

    "kubernetes.io/role/internal-elb" = "1"

    "kubernetes.io/cluster/platform-prod" = "shared"

    "karpenter.sh/discovery" = "platform-prod"
  }

  database_subnet_tags = {
    Tier = "Database"
  }

  tags = {
    Terraform = "true"
  }
}
