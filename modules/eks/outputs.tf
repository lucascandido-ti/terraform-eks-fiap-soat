output "cluster_id" {
  description = "EKS cluster ID."
  value       = aws_eks_cluster.cluster_eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.cluster_eks.endpoint
}

output "cluster_certificate_authority" {
  description = "value of the cluster's certificate authority."
  value       = aws_eks_cluster.cluster_eks.certificate_authority
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}
