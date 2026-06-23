data "terraform_remote_state" "route53" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/dns/route53.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "external_dns" {

  name = "ExternalDNSRoute53Policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets"
        ]

        Resource = [
          "arn:aws:route53:::hostedzone/${data.terraform_remote_state.route53.outputs.hosted_zone_id}"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "external_dns" {

  name = "PlatformExternalDNSRole"

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

resource "aws_iam_role_policy_attachment" "external_dns" {

  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_eks_pod_identity_association" "external_dns" {

  cluster_name = var.cluster_name

  namespace = "kube-system"

  service_account = "external-dns"

  role_arn = aws_iam_role.external_dns.arn

  depends_on = [
    aws_iam_role_policy_attachment.external_dns
  ]
}

resource "helm_release" "external_dns" {

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.18.0"

  namespace        = "kube-system"
  create_namespace = false

  wait    = true
  timeout = 600

  values = [
    yamlencode({

      provider = "aws"

      policy = "sync"

      domainFilters = [
        var.domain_name
      ]

      txtOwnerId = var.cluster_name

      serviceAccount = {
        create = true
        name   = "external-dns"
      }
    })
  ]

  depends_on = [
    aws_eks_pod_identity_association.external_dns
  ]
}
