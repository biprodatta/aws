/*
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "worker_ng" {

  node_group_name_prefix = "eks"
  node_group_name        = "nodegroup1"

  cluster_name  = var.cluster_name
  node_role_arn = var.node_role_arn
  subnet_ids    = [var.subnet_ids]

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  ami_type             = var.ami_type
  disk_size            = "20"
  instance_types       = var.instance_types
  version              = var.eks_cluster_version
  release_version      = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  capacity_type        = "ON_DEMAND"

# when you create this block with only ec2_ssh_key then it will open ssh or RDP port for 0.0.0.0/0
  remote_access {
    ec2_ssh_key               = var.ec2_ssh_key_pair_name
    source_security_group_ids = [var.ng_allowed_sg_id]
  }

  launch_template {
    id      = launch_template.value["id"]
    version = launch_template.value["version"]
  }
# https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
  taint {
    key    = "special"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  update_config {
    max_unavailable = 1
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  tags = merge(
    var.tags,
    map("creator", "bipro")
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }
  
  depends_on = [var.ng_depends_on]
}
*/