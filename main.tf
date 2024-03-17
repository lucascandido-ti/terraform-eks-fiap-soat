module "eks" {
  source              = "./modules/eks"
  cluster_name        = local.cluster_name
  private_subnets     = module.vpc.private_subnets
  instance_type_nodes = var.instance_type_nodes
  intra_subnets       = module.vpc.intra_subnets
  vpc_id              = module.vpc.vpc_id
  ami_type            = var.ami_type
  tags                = local.common_tags
}


module "vpc" {
  source       = "./modules/vpc"
  vpc_name     = local.vpc_name
  azs          = data.aws_availability_zones.available.names
  cluster_name = local.cluster_name
}
