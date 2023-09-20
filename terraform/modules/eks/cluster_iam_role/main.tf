data "aws_iam_policy_document" "passrole" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole", "iam:GetRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  name = "AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSVPCResourceController" {
  name = "AmazonEKSVPCResourceController"
}

resource "aws_iam_role" "eks_iam_cluster_role" {
  name = "eks_cluster_custom_role"
  description = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "passrole_policy" {
  name        = "cluster_passrole_policy"
  description = "cluster pass role policy"
  policy      = data.aws_iam_policy_document.passrole.json
}

resource "aws_iam_policy_attachment" "cluster_passrole_policy" {
  name       = "cluster_policy_attachment"
  roles      = [aws_iam_role.eks_iam_cluster_role.name]
  policy_arn = aws_iam_policy.passrole_policy.arn
}

resource "aws_iam_policy_attachment" "cluster_vpc_policy" {
  name       = "cluster_vpc_policy_attachment"
  roles      = [aws_iam_role.eks_iam_cluster_role.name]
  policy_arn = data.aws_iam_policy.AmazonEKSVPCResourceController.arn
}

resource "aws_iam_policy_attachment" "cluster_main_policy" {
  name       = "cluster_main_policy_attachment"
  roles      = [aws_iam_role.eks_iam_cluster_role.name]
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}