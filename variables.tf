variable "aws_region" {
  default = "us-east-1"
}

locals {
  cluster_name    = "tech-challenge-cluster"
  node_group_name = "tech-challenge-cluster-worker"
  vpc_name        = "tech-challenge-vpc"
  k8s_name_db     = "tech-challenge-kubernetes-db"
  k8s_name_api    = "tech-challenge-kubernetes-db"
  common_tags = {
    terraform = var.terraform
  }
}

variable "ami_type" {
  default = "AL2_x86_64"
}

variable "instance_type_nodes" {
  default = "t3.micro"
}

variable "desired_nodes" {
  type    = number
  default = 3
}

#tags
variable "terraform" {
  default = "True"
}
