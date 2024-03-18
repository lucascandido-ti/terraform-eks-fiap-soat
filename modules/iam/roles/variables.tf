variable "iam_eks_role_name" {
  default = "ClusterRoleEKS"
}

variable "iam_eks_policy_name" {
  default = "AmazonEKSClusterPolicy"
}

variable "iam_wn_role_name" {
  default = "ClusterRoleWorkerNode"
}


variable "iam_wn_policy_name_ec2" {
  default = "AmazonEC2ContainerRegistryReadOnly"
}

variable "iam_wn_policy_name_cni" {
  default = "AmazonEKS_CNI_Policy"
}

variable "iam_wn_policy_name_np" {
  default = "AmazonEKSWorkerNodePolicy"
}
