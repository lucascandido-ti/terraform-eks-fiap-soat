output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.cluster_eks_k8s.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.cluster_eks_k8s
}

output "cluster_certificate_authority" {
  description = "value of the cluster's certificate authority."
  value       = module.cluster_eks_k8s.cluster_certificate_authority
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "vpc_id" {
  description = "VPC Id of EKS."
  value       = module.vpc.vpc_id
}

