# eks_sg related output:
output "sg_id" {
  value = module.eks_sg.sg_id
}

# cluster iam role related output:
output "cluster_role_arn" {
  value = module.eks_iam_cluster_role.cluster_role_arn
}

# node group iam role related output:
output "ng_role_arn" {
  value = module.eks_iam_nodegroup_role.ng_role_arn
}

# EKS cluster related output:
output "endpoint" {
  value = module.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = module.eks_cluster.kubeconfig-certificate-authority-data
}

output "eks_cluster_version" {
  value = module.eks_cluster.eks_cluster_version
}