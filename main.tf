module "vpc" {
  source       = "./modules/vpc"
  vpc_name     = local.vpc_name
  azs          = data.aws_availability_zones.available.names
  cluster_name = local.cluster_name
}

module "cluster_eks_k8s" {
  source     = "./modules/eks"
  aws_region = var.aws_region

  cluster_name        = local.cluster_name
  node_group_name     = local.node_group_name
  private_subnets     = module.vpc.private_subnets
  instance_type_nodes = var.instance_type_nodes
  intra_subnets       = module.vpc.intra_subnets
  vpc_id              = module.vpc.vpc_id
  ami_type            = var.ami_type
  tags                = local.common_tags

  cluster_token = data.aws_eks_cluster_auth.cluster.token

  k8s_name_db  = local.k8s_name_db
  k8s_name_api = local.k8s_name_api

  helm_repo             = local.helm_database.repository
  helm_chart_db         = local.helm_database.name
  helm_chart_version_db = local.helm_database.version

  helm_chart_api         = local.helm_application.name
  helm_chart_version_api = local.helm_application.version

}
