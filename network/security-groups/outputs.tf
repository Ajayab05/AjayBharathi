output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "eks_cluster_sg_id" {
  value = aws_security_group.eks_cluster.id
}

output "node_sg_id" {
  value = aws_security_group.node.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
