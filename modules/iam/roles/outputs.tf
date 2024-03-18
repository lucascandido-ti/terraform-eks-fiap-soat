# Output para o ID da Role do EKS
output "eks_role_id" {
  value       = aws_iam_role.eks_role.id
  description = "O ID da IAM Role criada para o EKS."
}

# Output para o ID da Role dos Worker Nodes
output "wn_role_id" {
  value       = aws_iam_role.wn_role.id
  description = "O ID da IAM Role criada para os Worker Nodes."
}
