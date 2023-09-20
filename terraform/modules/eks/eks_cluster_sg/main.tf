data "aws_vpc" "myvpc" {
  id = var.vpc_id
}

resource "aws_security_group" "eks_sg" {
  name        = "eks_sg"
  description = "security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description      = "all trafic from vpc"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.myvpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}