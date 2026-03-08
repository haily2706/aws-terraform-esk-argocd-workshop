# terraform/outputs.tf
# ─────────────────────────────────────────────────────────────────
# Outputs — useful info displayed after terraform apply.
# ─────────────────────────────────────────────────────────────────

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

output "configure_kubectl" {
  description = "Run this command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}