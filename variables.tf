variable "aws_region" {
  default = "us-east-1"
}

locals {
  cluster_name    = "tech-challenge-cluster"
  node_group_name = "tech-challenge-cluster-worker"
  vpc_name        = "tech-challenge-vpc"
  k8s_name_db     = "tech-challenge-kubernetes-db"
  k8s_name_api    = "tech-challenge-kubernetes-api"

  helm_database = {
    repository = "https://lucascandido-ti.github.io/helm-tech-challenge-soat"
    name       = "database-tech-challenge"
    version    = "0.1.0"
  }

  helm_application = {
    repository = "https://lucascandido-ti.github.io/helm-tech-challenge-soat"
    name       = "application-tech-challenge"
    version    = "0.1.0"
  }

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
