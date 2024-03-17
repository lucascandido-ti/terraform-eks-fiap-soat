
locals {
  ami_type            = var.ami_type
  instance_type_nodes = var.instance_type_nodes
}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.0"
  cluster_name                   = var.cluster_name
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  control_plane_subnet_ids       = var.intra_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = var.ami_type
    instance_types = [var.instance_type_nodes]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    tech-eks-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = [var.instance_type_nodes]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = var.tags
}
