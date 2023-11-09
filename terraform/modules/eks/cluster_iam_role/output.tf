output "cluster_role_arn" {
  value = aws_iam_role.eks_iam_cluster_role.arn
}

output "alb_controller_policy_arn" {
  value = aws_iam_policy.aws_alb_controller_policy.arn
}

