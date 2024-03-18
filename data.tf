
data "aws_caller_identity" "current" {
}
data "aws_region" "current" {
  name = var.aws_region
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "cluster" {
  name = module.cluster_eks_k8s.cluster_name
}
