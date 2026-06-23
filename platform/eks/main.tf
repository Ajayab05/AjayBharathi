module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  endpoint_public_access  = true
  endpoint_private_access = true

  authentication_mode = "API_AND_CONFIG_MAP"

  create_iam_role = false
  iam_role_arn    = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn

  enable_irsa = true

  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  addons = {

    vpc-cni = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    coredns = {
      most_recent = true
    }

    eks-pod-identity-agent = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
  most_recent = true
    }
  }

  eks_managed_node_groups = {

    system = {

      iam_role_arn = data.terraform_remote_state.iam.outputs.eks_node_role_arn

      instance_types = ["t3.large"]

      ami_type = "AL2023_x86_64_STANDARD"

      min_size     = 3
      max_size     = 6
      desired_size = 3

      subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

      update_config = {
        max_unavailable_percentage = 25
      }

      tags = {
        Name = "platform-prod-system"
      }
    }
  }

  tags = {
    Environment = "prod"
    Project     = "platform"
    Terraform   = "true"
  }
}
