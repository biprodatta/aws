output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_cluster_version" {
  value = aws_eks_cluster.eks_cluster.version
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}