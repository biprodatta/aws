# module "s3_bucket" {
#   source = "./modules/s3"
# }

module "eks_sg" {
  source = "./modules/eks/eks_cluster_sg"

  vpc_id = var.vpc_id
}

module "eks_iam_cluster_role" {
  source = "./modules/eks/cluster_iam_role"
}

module "eks_iam_nodegroup_role" {
  source = "./modules/eks/nodegroup_iam_role"
}

module "eks_cluster" {
  source = "./modules/eks/eks_cluster"

  role_arn = module.eks_iam_cluster_role.cluster_role_arn
  vpc_id = var.vpc_id
  cluster_sg_id = module.eks_sg.sg_id
}

# module "eks_nodegroup" {
#   source = "./modules/eks/eks_nodegroup"

#   eks_cluster_version = module.eks_cluster.eks_cluster_version
  
# }

module "eks_ng_working" {
  source = "./modules/eks/eks_ng_working"

  cluster_name  = module.eks_cluster.cluster_name
  ng_role_arn      = module.eks_iam_nodegroup_role.ng_role_arn
  vpc_id        = var.vpc_id
  cluster_sg_id = module.eks_sg.sg_id
  
}