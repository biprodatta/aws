# data "aws_vpc" "vpc" {
#   id = var.vpc_id
# }

# data "aws_subnet" "subnet1" {
#   id = var.subnet1_id
# }

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "all_subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

# data "aws_security_group" "cluster_sg" {
# #   id = var.cluster_sg_id
#   id = "sg-0fa5d4d666028ad8e"
# }



resource "aws_eks_cluster" "eks_cluster" {
  name     = "test"
  role_arn = var.role_arn

  vpc_config {
    security_group_ids      = [var.cluster_sg_id]
    subnet_ids = [for s in data.aws_subnet.all_subnet : s.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.

}

### OIDC config
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}