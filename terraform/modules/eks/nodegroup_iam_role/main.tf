data "aws_iam_policy_document" "passrole" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole", "iam:GetRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}
data "aws_iam_policy" "AmazonEBSCSIDriverPolicy" {
  name = "AmazonEBSCSIDriverPolicy"
}
data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  name = "AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "eks_iam_nodegroup_role" {
  name = "eks_nodegroup_custom_role"
  description = "Allows access to other AWS service resources that are required bt nodegroup to operate clusters managed by EKS."

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
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ng_passrole_policy" {
  name        = "ng_passrole_policy"
  description = "nodegroup pass role policy"
  policy      = data.aws_iam_policy_document.passrole.json
}

resource "aws_iam_policy_attachment" "ng_passrole_policy_attachment" {
  name       = "ng_passrole_policy_attachment"
  roles      = [aws_iam_role.eks_iam_nodegroup_role.name]
  policy_arn = aws_iam_policy.ng_passrole_policy.arn
}

resource "aws_iam_policy_attachment" "ng_policy" {
  name       = "ng_policy"
  roles      = [aws_iam_role.eks_iam_nodegroup_role.name]
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
}

resource "aws_iam_policy_attachment" "ng_ecr_policy" {
  name       = "ng_ecr_policy"
  roles      = [aws_iam_role.eks_iam_nodegroup_role.name]
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}


resource "aws_iam_policy_attachment" "csi_policy" {
  name       = "csi_policy"
  roles      = [aws_iam_role.eks_iam_nodegroup_role.name]
  policy_arn = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
}

resource "aws_iam_policy_attachment" "cni_policy" {
  name       = "cni_policy"
  roles      = [aws_iam_role.eks_iam_nodegroup_role.name]
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
}