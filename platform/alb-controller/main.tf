data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/network/vpc.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "alb" {

  name = "AWSLoadBalancerControllerPolicy"

  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role" "alb_controller" {

  name = "PlatformALBControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb" {

  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb.arn
}

resource "aws_eks_pod_identity_association" "alb" {

  cluster_name = var.cluster_name

  namespace = "kube-system"

  service_account = "aws-load-balancer-controller"

  role_arn = aws_iam_role.alb_controller.arn

  depends_on = [
    aws_iam_role_policy_attachment.alb
  ]
}

resource "helm_release" "alb" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.4.0"

  namespace        = "kube-system"
  create_namespace = false

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      clusterName = var.cluster_name

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }

      region = "us-east-1"

      vpcId = data.terraform_remote_state.vpc.outputs.vpc_id
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.alb
  ]
}
