output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node.arn
}
