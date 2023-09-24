variable "cluster_name" {
  type = string
}


variable "node_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = string
}

variable "desired_capacity" {
  type = string
}

variable "max_capacity" {
  type = string
}

variable "min_capacity" {
  type = string
}

variable "ami_type" {
  type = string
}

variable "instance_types" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "ec2_ssh_key_pair_name" {
  type = string
}
variable "ng_allowed_sg_id" {
  type = string
}

variable "ng_sg_id" {
  type = string
}

variable "ng_depends_on" {
  type = string
}