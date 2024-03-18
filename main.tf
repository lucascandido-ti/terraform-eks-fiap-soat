module "iam" {
  source = "./modules/iam/roles"
}

module "eks" {
  source                       = "./modules/eks"
  cluster_name                 = local.cluster_name
  node_group_name              = local.node_group_name
  private_subnets              = module.vpc.private_subnets
  instance_type_nodes          = var.instance_type_nodes
  intra_subnets                = module.vpc.intra_subnets
  vpc_id                       = module.vpc.vpc_id
  ami_type                     = var.ami_type
  tags                         = local.common_tags
  cluster_security_group_id    = module.iam.eks_role_id
  workernode_security_group_id = module.iam.wn_role_id
}

module "vpc" {
  source       = "./modules/vpc"
  vpc_name     = local.vpc_name
  azs          = data.aws_availability_zones.available.names
  cluster_name = local.cluster_name
}

module "security_group" {
  source                     = "./modules/security-group"
  balancers_sg_name          = "balancers-security-group"
  balancers_sg_description   = "Permite trafego do api gateway ate o ecs"
  eks_cluster_sg_name        = "cluster-security-group"
  eks_cluster_sg_description = "Grupo de seguranca do cluster"
  vpc_id                     = module.vpc.vpc_id
}

module "k8s_database" {
  source                        = "./modules/k8s/database"
  k8s_name_db                   = local.k8s_name_db
  cluster_name                  = local.cluster_name
  cluster_id                    = module.eks.cluster_id
  cluster_endpoint              = module.eks.cluster_endpoint
  cluster_certificate_authority = base64decode(module.eks.cluster_certificate_authority.0.data)
  cluster_token                 = data.aws_eks_cluster_auth.cluster.token
}
